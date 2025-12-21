import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/anime_path_provider.dart';
import 'package:flutter_application_1/providers/anime_sections_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
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
    final animeImage = await AnimePathProvider.getLocalFileImage(anime);
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
    final file = await AnimePathProvider.getLocalFileImage(anime);
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
      final cachedAnimes = await AnimeSectionsProvider.instance.getAnimes(
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
          AnimeSectionsProvider.instance.saveSection(section, animes);
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
      final cachedAnimes = await AnimeSectionsProvider.instance.getAnimes(
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
          AnimeSectionsProvider.instance.saveSection(section, animes);
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
      final cachedAnimes = await AnimeSectionsProvider.instance.getAnimes(
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
          AnimeSectionsProvider.instance.saveSection(section, animes);
        }
        return animes;
      } catch (e) {
        debugPrint("[AnimeRepository] getMostLikedAnimes: $e");
      }
    }

    return [];
  }
}
