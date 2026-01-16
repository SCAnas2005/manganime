import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/providers/user_profile_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/network_service.dart';

class MangaRepository {
  final ApiService api;

  MangaRepository({required this.api});

  Manga? getMangaFromCache(int id) {
    final data = MangaCache.instance.get(id);
    return data;
  }

  Future<Manga?> getMangaFromDatabase(int id) async {
    var data = await DatabaseProvider.instance.getManga(id);
    return data;
  }

  Future<Manga?> getMangaFromService(int id) async {
    if (await NetworkService.isConnected) {
      try {
        final data = await RequestQueue.instance.enqueue(
          () => api.getFullDetailManga(id),
        );
        return data;
      } catch (e) {
        debugPrint(
          "[MangaRepository] getMangaFromService($id): manga $id not found on api",
        );
        return null;
      }
    }
    return null;
  }

  Future<void> saveMangaOnCache(Manga manga) async {
    await MangaCache.instance.save(manga);
  }

  Future<Manga?> getManga(int id) async {
    // 1. Cache
    var data = getMangaFromCache(id);
    if (data != null) {
      return data;
    }

    // 2. Database
    data = await getMangaFromDatabase(id);
    if (data != null) return data;

    // 3. API
    final manga = await getMangaFromService(id);
    if (manga != null) {
      // 4. Sauvegarde
      saveMangaOnCache(manga);
    }
    return manga;
  }

  Future<Image> getMangaImage(Manga manga) async {
    // Recherche dans les fichiers de l'app
    final mangaImage = await MediaPathProvider.getLocalFileImage<Manga>(manga);
    if (mangaImage.existsSync()) {
      return Image.file(mangaImage, fit: BoxFit.cover);
    }

    if (await NetworkService.isConnected) {
      return Image.network(manga.imageUrl, fit: BoxFit.cover);
    } else {
      throw Exception(
        "[MangaRepository] getMangaImage: Error can't access image",
      );
    }
  }

  Future<ImageProvider?> getMangaImageProvider(Manga manga) async {
    final file = await MediaPathProvider.getLocalFileImage<Manga>(manga);
    if (file.existsSync()) {
      return FileImage(file);
    }

    if (await NetworkService.isConnected) {
      return NetworkImage(
        manga.imageUrl,
        headers: {'User-Agent': 'MangAnime/1.0'},
      );
    }

    return null;
  }

  Future<List<Manga>> getPopularMangas({int page = 1}) async {
    final section = MangaSections.popular;
    if (page == 1) {
      // Database
      final cachedMangas = await MediaSectionsProvider.instance.getMangas(
        section,
      );
      if (cachedMangas.isNotEmpty) return cachedMangas;
    }
    // Api
    if (await NetworkService.isConnected) {
      try {
        final mangas = await RequestQueue.instance.enqueue(
          () => api.getTopManga(page: page, filter: "bypopularity"),
        );

        // Save dans le cache si page 1
        if (page == 1) {
          await MediaSectionsProvider.instance.saveMangaSection(
            section,
            mangas,
          );
        }
        return mangas;
      } catch (e) {
        debugPrint("[$MangaRepository] getPopularMangas: $e");
      }
    }

    return [];
  }

  Future<List<Manga>> getPublishingMangas({int page = 1}) async {
    final section = MangaSections.airing;
    if (page == 1) {
      // Database
      final cachedMangas = await MediaSectionsProvider.instance.getMangas(
        section,
      );
      if (cachedMangas.isNotEmpty) return cachedMangas;
    }
    // Api
    if (await NetworkService.isConnected) {
      try {
        final mangas = await RequestQueue.instance.enqueue(
          () => api.getTopManga(page: page, filter: MediaStatus.publishing.key),
        );

        // Save dans le cache si page 1
        if (page == 1) {
          await MediaSectionsProvider.instance.saveMangaSection(
            section,
            mangas,
          );
        }
        return mangas;
      } catch (e) {
        debugPrint("[$MangaRepository] getPublishingMangas: $e");
      }
    }
    return [];
  }

  Future<List<Manga>> getMostLikedMangas({int page = 1}) async {
    final section = MangaSections.mostLiked;
    if (page == 1) {
      // Database
      final cachedMangas = await MediaSectionsProvider.instance.getMangas(
        section,
      );
      if (cachedMangas.isNotEmpty) return cachedMangas;
    }
    // Api
    if (await NetworkService.isConnected) {
      try {
        final mangas = await RequestQueue.instance.enqueue(
          () => api.getTopManga(page: page, filter: "favorite"),
        );

        // Save dans le cache si page 1
        if (page == 1) {
          await MediaSectionsProvider.instance.saveMangaSection(
            section,
            mangas,
          );
        }
        return mangas;
      } catch (e) {
        debugPrint("[$MangaRepository] getMostLikedMangas: $e");
      }
    }

    return [];
  }

  Future<List<Manga>> getForYouManga(
    GlobalMangaFavoritesProvider provider, {
    int page = 1,
  }) async {
    final liked = provider.loadedFavoriteMangas;

    // Calcul du profil utilisateur
    final userProfile = UserprofileProvider.create(likedMangas: liked);
    debugPrint("User profil built: $userProfile");

    // Le top genres
    final topGenres = userProfile.getTopGenres<Manga>(3);
    if (topGenres.length >= 3) {
      debugPrint(
        "Manga Top genres: ${topGenres.first}, ${topGenres[1]}, ${topGenres[2]}",
      );
    }

    if (topGenres.isEmpty) {
      return await getPopularMangas();
    }

    List<Manga> candidates = [];

    try {
      // 1. API
      if (await NetworkService.isConnected) {
        candidates = await RequestQueue.instance.enqueue(
          () => api.searchManga(page: page, query: "", genres: topGenres),
        );
        debugPrint("fetchForYou mangas count : ${candidates.length}");
      } else {
        candidates = await DatabaseProvider.instance.search<Manga>(
          page: page,
          query: "",
          genres: topGenres,
        );
      }

      debugPrint("Removing liked mangas from suggestions");
      final likedIds = liked.map((e) => e.id).toSet();
      candidates = candidates.where((a) => !likedIds.contains(a.id)).toList();

      candidates.sort((a, b) {
        final scoreA = userProfile.calculateScoreFor<Manga>(a);
        final scoreB = userProfile.calculateScoreFor<Manga>(b);

        // compareTo inversé (B vers A) pour avoir l'ordre Décroissant (Plus grand score en haut)
        return scoreB.compareTo(scoreA);
      });

      debugPrint("fetchForYou mangas count : ${candidates.length}");
      return candidates;
    } catch (e) {
      debugPrint("[MangaRepository] getForYouManga: $e");
    }

    return [];
  }

  Future<Manga?> getMangaOfTheDay() async {
    final mangas = await getPopularMangas();
    if (mangas.isNotEmpty) {
      return mangas.first;
    }
    return null;
  }

  Future<List<Manga>> search({
    required String query,
    int page = 1,
    List<Genres>? genres,
    MediaStatus? status,
    MediaOrderBy? orderBy,
    SortOrder? sort,
    MangaType? mangaType,
  }) async {
    if (await NetworkService.isConnected) {
      try {
        final candidates = await RequestQueue.instance.enqueue(
          () => api.searchManga(
            page: page,
            query: query,
            genres: genres,
            status: status,
            orderBy: orderBy,
            sort: sort,
            type: mangaType,
          ),
        );

        return candidates;
      } catch (e) {
        debugPrint("[MangaRepository] search() : Erreur $e");
      }
    }

    final results = await DatabaseProvider.instance.search<Manga>(
      page: page,
      query: query,
      genres: genres,
      status: status,
      orderBy: orderBy,
      mangaType: mangaType,
    );
    return results;
  }
}
