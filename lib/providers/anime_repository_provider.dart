import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/media_sections_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';
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
      debugPrint("Airing animes len : ${cachedAnimes.length}");
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

  // Future<List<Anime>> getForYouAnimes(
  //   GlobalAnimeFavoritesProvider provider, {
  //   int page = 1,
  // }) async {
  //   final liked = provider.loadedFavoriteAnimes;

  //   var settingsProvider = SettingsRepositoryProvider(SettingsStorage.instance);

  //   final preferredGenres = settingsProvider.getSettings().favoriteGenres ?? [];
  //   // Calcul du profil utilisateur
  //   final userProfile = UserprofileProvider.create(
  //     likedAnimes: liked,
  //     preferredGenres: preferredGenres,
  //   );
  //   debugPrint("User profil built: $userProfile");

  //   // Le top genres
  //   final topGenres = userProfile.getTopGenres<Anime>(2);

  //   List<Anime> mixedCandidates = [];

  //   if (topGenres.length >= 3) {
  //     debugPrint("Top genres: ${topGenres.first}, ${topGenres[1]}");
  //   }

  //   if (topGenres.isEmpty) {
  //     debugPrint("Aucune top genres, retour des popular animes");
  //     return await getPopularAnimes(page: page);
  //   }

  //   List<Anime> candidates = [];

  //   try {
  //     // 1. API
  //     if (await NetworkService.isConnected) {
  //       candidates = await RequestQueue.instance.enqueue(
  //         () => api.searchAnime(page: page, query: "", genres: topGenres),
  //       );
  //       debugPrint("fetchForYou animes count : ${candidates.length}");
  //     } else {
  //       candidates = await DatabaseProvider.instance.search<Anime>(
  //         page: page,
  //         query: "",
  //         genres: topGenres,
  //       );
  //     }

  //     debugPrint("Removing liked animes from suggestions");
  //     final likedIds = liked.map((e) => e.id).toSet();
  //     candidates = candidates.where((a) => !likedIds.contains(a.id)).toList();

  //     candidates.sort((a, b) {
  //       final scoreA = userProfile.calculateScoreFor<Anime>(a);
  //       final scoreB = userProfile.calculateScoreFor<Anime>(b);

  //       // compareTo inversé (B vers A) pour avoir l'ordre Décroissant (Plus grand score en haut)
  //       return scoreB.compareTo(scoreA);
  //     });

  //     debugPrint("fetchForYou animes count : ${candidates.length}");
  //     return candidates;
  //   } catch (e) {
  //     debugPrint("[AnimeRepository] getForYouAnimes: $e");
  //   }

  //   return [];
  // }

  Future<List<Anime>> getForYouAnimes(
    GlobalAnimeFavoritesProvider provider, {
    int page = 1,
  }) async {
    final liked = provider.loadedFavoriteAnimes;

    var settingsProvider = SettingsRepositoryProvider(SettingsStorage.instance);

    final preferredGenres = settingsProvider.getSettings().favoriteGenres ?? [];

    // Récupérer les settings ici si possible
    final userProfile = UserprofileProvider.create(
      likedAnimes: liked,
      preferredGenres: preferredGenres,
    );

    // On prend le Top 2 au lieu du Top 3
    final topGenres = userProfile.getTopGenres<Anime>(2);

    List<Anime> mixedCandidates = [];

    // SI PAS ASSEZ DE DONNÉES -> POPULAIRE
    if (topGenres.isEmpty) {
      return await getPopularAnimes(page: page); // Fallback
    }

    try {
      if (await NetworkService.isConnected) {
        // --- LA STRATÉGIE COCKTAIL ---

        // 1. Le genre Principal (ex: Aventure) - On en demande le plus
        final listA = await RequestQueue.instance.enqueue(
          () => api.searchAnime(query: "", page: page, genres: [topGenres[0]]),
        );

        // 2. Le genre Secondaire (ex: Fantasy) - On en demande aussi
        List<Anime> listB = [];
        if (topGenres.length > 1) {
          listB = await RequestQueue.instance.enqueue(
            () =>
                api.searchAnime(query: "", page: page, genres: [topGenres[1]]),
          );
        }

        // 3. L'Épice (Découverte) - Une page "Top Airing" ou un genre au hasard
        // Pour casser la routine, on injecte un peu de "Airing"
        final listDiscovery = await getAiringAnimes(page: page);

        // --- LE MÉLANGE ---

        // On combine tout (Set pour éviter les doublons si un anime est Aventure ET Fantasy)
        final Set<Anime> uniqueSet = {};
        uniqueSet.addAll(listA); // Beaucoup de genre 1
        uniqueSet.addAll(listB); // Un peu de genre 2
        uniqueSet.addAll(
          listDiscovery.take(5),
        ); // Un peu de nouveauté (limité à 5)

        mixedCandidates = uniqueSet.toList();
      } else {
        // Mode Hors ligne (DB)
        mixedCandidates = await DatabaseProvider.instance.search<Anime>(
          page: page,
          genres: topGenres, // En local on reste simple
        );
      }

      // --- FILTRAGE ET TRI ---

      // 1. On retire ce qu'on a déjà vu/liké
      final likedIds = liked.map((e) => e.id).toSet();
      mixedCandidates.removeWhere((a) => likedIds.contains(a.id));

      // 2. On trie par score pour mettre le plus pertinent en haut
      mixedCandidates.sort((a, b) {
        final scoreA = userProfile.calculateScoreFor<Anime>(a);
        final scoreB = userProfile.calculateScoreFor<Anime>(b);
        return scoreB.compareTo(scoreA);
      });

      // 3. PETITE TOUCHE FINALE : Le Shuffle partiel
      // Si les scores sont très proches (ex: plein d'animes on le même score),
      // on veut que ça bouge un peu. On ne shuffle pas tout (sinon le score sert à rien),
      // mais on peut mélanger des petits groupes.
      // OU plus simple : On prend le top 20 trié, et on le mélange pour l'affichage
      // return mixedCandidates; // Version triée stricte

      return mixedCandidates;
    } catch (e) {
      debugPrint("Error strategy cocktail: $e");
      return [];
    }
  }

  Future<List<Anime>> search({
    required String query,
    int page = 1,
    List<Genres>? genres,
    MediaStatus? status,
    MediaOrderBy? orderBy,
    SortOrder? sort,
    AnimeType? animeType,
    AnimeRating? animeRating,
  }) async {
    if (await NetworkService.isConnected) {
      try {
        final candidates = await RequestQueue.instance.enqueue(
          () => api.searchAnime(
            page: page,
            query: query,
            genres: genres,
            status: status,
            orderBy: orderBy,
            sort: sort,
            type: animeType,
            rating: animeRating,
          ),
        );

        return candidates;
      } catch (e) {
        debugPrint("[AnimeRepository] search() : Erreur $e");
      }
    }
    final results = await DatabaseProvider.instance.search<Anime>(
      page: page,
      query: query,
      genres: genres,
      status: status,
      orderBy: orderBy,
      animeType: animeType,
      animeRating: animeRating,
    );
    return results;
  }

  Future<Anime?> getAnimeOfTheDay() async {
    final animes = await getPopularAnimes();
    return animes.isNotEmpty ? animes.first : null;
  }
}
