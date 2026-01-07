import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/providers/user_profile_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/network_service.dart';

class AnimeRepository {
  final ApiService api;

  AnimeRepository({required this.api});

  Future<void> loadAnimes() async {}

  Future<Anime?> getAnimeFromCache(int id) async {
    var data = await AnimeCache.instance.get(id);
    return data;
  }

  Future<Anime?> getAnimeFromDatabase(int id) async {
    var data = await DatabaseProvider.instance.getAnime(id);
    return data;
  }

  Future<Anime?> getAnimeFromService(int id) async {
    Anime? anime;
    if (await NetworkService.isConnected) {
      anime = await RequestQueue.instance.enqueue(
        () => api.getFullDetailAnime(id),
      );
    }
    return anime;
  }

  Future<void> saveAnimeInCache(Anime anime) async {
    await AnimeCache.instance.save(anime);
  }

  Future<Anime?> getAnime(int id) async {
    // 1. Cache
    var data = await getAnimeFromCache(id);
    if (data != null) return data;

    // 2. Base de donnée
    data = await getAnimeFromDatabase(id);
    if (data != null) return data;

    // 3. Api
    data = await getAnimeFromService(id);
    if (data != null) {
      await saveAnimeInCache(data);
      return data;
    }
    return null;
  }

  Future<Image> getAnimeImage(Anime anime) async {
    // Recherche dans les fichiers de l'app
    final animeImage = await MediaPathProvider.getLocalFileImage<Anime>(anime);
    if (animeImage.existsSync()) {
      return Image.file(animeImage, fit: BoxFit.cover);
    }

    if (await NetworkService.isConnected) {
      return Image.network(anime.imageUrl, fit: BoxFit.cover);
    } else {
      throw Exception("Error can't access image");
    }
  }

  Future<ImageProvider?> getAnimeImageProvider(Anime anime) async {
    final file = await MediaPathProvider.getLocalFileImage<Anime>(anime);
    if (file.existsSync()) {
      return FileImage(file);
    }

    if (await NetworkService.isConnected) {
      return NetworkImage(
        anime.imageUrl,
        headers: {'User-Agent': 'MangAnime/1.0'},
      );
    }

    return null;
  }

  Future<List<Anime>> getPopularAnimes({int page = 1}) async {
    final section = AnimeSections.popular;
    if (page == 1) {
      // Database
      final cachedAnimes = await MediaSectionsProvider.instance.getAnimes(
        section,
      );
      if (cachedAnimes.isNotEmpty) return cachedAnimes;
    }
    // Api
    if (await NetworkService.isConnected) {
      try {
        final animes = await RequestQueue.instance.enqueue(
          () => api.getTopAnime(page: page, filter: "bypopularity"),
        );

        // Save dans le cache si page 1
        if (page == 1) {
          await MediaSectionsProvider.instance.saveAnimeSection(
            section,
            animes,
          );
        }
        return animes;
      } catch (e) {
        debugPrint("[AnimeRepository] getPopularAnimes: $e");
      }
    }

    return [];
  }

  Future<List<Anime>> getAiringAnimes({int page = 1}) async {
    final section = AnimeSections.airing;
    if (page == 1) {
      // Database
      final cachedAnimes = await MediaSectionsProvider.instance.getAnimes(
        section,
      );
      if (cachedAnimes.isNotEmpty) return cachedAnimes;
    }
    // Api
    if (await NetworkService.isConnected) {
      try {
        final animes = await RequestQueue.instance.enqueue(
          () => api.getSeasonAnimes(page: page),
        );

        // Save dans le cache si page 1
        if (page == 1) {
          await MediaSectionsProvider.instance.saveAnimeSection(
            section,
            animes,
          );
        }
        return animes;
      } catch (e) {
        debugPrint("[AnimeRepository] getAiringAnimes: $e");
      }
    }
    return [];
  }

  Future<List<Anime>> getMostLikedAnimes({int page = 1}) async {
    final section = AnimeSections.mostLiked;
    if (page == 1) {
      // Database
      final cachedAnimes = await MediaSectionsProvider.instance.getAnimes(
        section,
      );
      if (cachedAnimes.isNotEmpty) return cachedAnimes;
    }
    // Api
    if (await NetworkService.isConnected) {
      try {
        final animes = await RequestQueue.instance.enqueue(
          () => api.getTopAnime(page: page, filter: "favorite"),
        );

        // Save dans le cache si page 1
        if (page == 1) {
          await MediaSectionsProvider.instance.saveAnimeSection(
            section,
            animes,
          );
        }
        return animes;
      } catch (e) {
        debugPrint("[AnimeRepository] getMostLikedAnimes: $e");
      }
    }

    return [];
  }

  Future<List<Anime>> getForYouAnimes(
    GlobalAnimeFavoritesProvider provider, {
    int page = 1,
  }) async {
    final liked = provider.loadedFavoriteAnimes;

    // Calcul du profil utilisateur
    final userProfile = UserprofileProvider.create(likedAnimes: liked);
    debugPrint("User profil built: $userProfile");

    // Le top genres
    final topGenres = userProfile.getTopGenres<Anime>(3);
    if (topGenres.length >= 3) {
      debugPrint(
        "Top genres: ${topGenres.first}, ${topGenres[1]}, ${topGenres[2]}",
      );
    }

    if (topGenres.isEmpty) {
      return await getPopularAnimes();
    }

    List<Anime> candidates = [];

    try {
      // 1. API
      if (await NetworkService.isConnected) {
        candidates = await RequestQueue.instance.enqueue(
          () => api.search(page: page, query: "", genres: topGenres),
        );
        debugPrint("fetchForYou animes count : ${candidates.length}");
      } else {
        candidates = await DatabaseProvider.instance.search<Anime>(
          query: "",
          genres: topGenres,
        );
      }

      debugPrint("Removing liked animes from suggestions");
      final likedIds = liked.map((e) => e.id).toSet();
      candidates = candidates.where((a) => !likedIds.contains(a.id)).toList();

      candidates.sort((a, b) {
        final scoreA = userProfile.calculateScoreFor<Anime>(a);
        final scoreB = userProfile.calculateScoreFor<Anime>(b);

        // compareTo inversé (B vers A) pour avoir l'ordre Décroissant (Plus grand score en haut)
        return scoreB.compareTo(scoreA);
      });

      debugPrint("fetchForYou animes count : ${candidates.length}");
      return candidates;
    } catch (e) {
      debugPrint("[AnimeRepository] getForYouAnimes: $e");
    }

    return [];
  }
}
