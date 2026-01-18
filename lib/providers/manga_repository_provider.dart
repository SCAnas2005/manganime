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
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
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

    // 1. Récupération des préférences
    var settingsProvider = SettingsRepositoryProvider(SettingsStorage.instance);
    final preferredGenres = settingsProvider.getSettings().favoriteGenres ?? [];

    // 2. Création du profil utilisateur
    final userProfile = UserprofileProvider.create(
      likedMangas: liked,
      preferredGenres: preferredGenres,
    );

    // 3. On récupère le Top 2 (Principal + Nuance)
    final topGenres = userProfile.getTopGenres<Manga>(2);

    // Fallback : Si pas de préférences, on renvoie les populaires
    if (topGenres.isEmpty) {
      return await getPopularMangas(page: page);
    }

    List<Manga> mixedCandidates = [];

    try {
      // --- MODE ONLINE : STRATÉGIE COCKTAIL ---
      if (await NetworkService.isConnected) {
        // A. L'Ingrédient Principal (Genre N°1)
        final listA = await RequestQueue.instance.enqueue(
          () => api.searchManga(page: page, query: "", genres: [topGenres[0]]),
        );

        // B. La Nuance (Genre N°2)
        List<Manga> listB = [];
        if (topGenres.length > 1) {
          listB = await RequestQueue.instance.enqueue(
            () =>
                api.searchManga(page: page, query: "", genres: [topGenres[1]]),
          );
        }

        // C. L'Épice (Découverte)
        // On injecte quelques mangas populaires du moment pour varier
        final listDiscovery = await getPopularMangas(page: page);

        // D. Le Mélange (Set pour éviter les doublons)
        final Set<Manga> uniqueSet = {};
        uniqueSet.addAll(listA); // Majorité de Genre 1
        uniqueSet.addAll(listB); // Un peu de Genre 2
        uniqueSet.addAll(
          listDiscovery.take(5),
        ); // 5 Mangas populaires "au hasard"

        mixedCandidates = uniqueSet.toList();
      } else {
        // --- MODE OFFLINE : RECHERCHE CLASSIQUE ---
        mixedCandidates = await DatabaseProvider.instance.search<Manga>(
          page: page,
          query: "",
          genres: topGenres,
        );
      }

      // 4. NETTOYAGE
      // On retire les mangas qu'on a DÉJÀ likés
      final likedIds = liked.map((e) => e.id).toSet();
      mixedCandidates.removeWhere((m) => likedIds.contains(m.id));

      // 5. CLASSEMENT INTELLIGENT
      // On trie par score pour que les plus pertinents remontent
      mixedCandidates.sort((a, b) {
        final scoreA = userProfile.calculateScoreFor<Manga>(a);
        final scoreB = userProfile.calculateScoreFor<Manga>(b);
        return scoreB.compareTo(scoreA); // Décroissant
      });

      debugPrint(
        "🍹 Cocktail Manga servi : ${mixedCandidates.length} titres (Top: ${topGenres.first.toReadableString()})",
      );
      return mixedCandidates;
    } catch (e) {
      debugPrint("[MangaRepository] getForYouManga Error: $e");
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
