import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
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
        final data = await api.getFullDetailManga(id);
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

  // Future<List<Anime>> getPopularAnimes({int page = 1}) async {
  //   final section = AnimeSections.popular;
  //   if (page == 1) {
  //     // Database
  //     final cachedAnimes = await AnimeSectionsProvider.instance.getAnimes(
  //       section,
  //     );
  //     if (cachedAnimes.isNotEmpty) return cachedAnimes;
  //   }
  //   // Api
  //   if (await NetworkService.isConnected) {
  //     try {
  //       final animes = await RequestQueue.instance.enqueue(
  //         () => api.getTopAnime(page: page, filter: "bypopularity"),
  //       );

  //       // Save dans le cache si page 1
  //       if (page == 1) {
  //         AnimeSectionsProvider.instance.saveSection(section, animes);
  //       }
  //       return animes;
  //     } catch (e) {
  //       debugPrint("[AnimeRepository] getPopularAnimes: $e");
  //     }
  //   }

  //   return [];
  // }

  // Future<List<Anime>> getAiringAnimes({int page = 1}) async {
  //   final section = AnimeSections.airing;
  //   if (page == 1) {
  //     // Database
  //     final cachedAnimes = await AnimeSectionsProvider.instance.getAnimes(
  //       section,
  //     );
  //     if (cachedAnimes.isNotEmpty) return cachedAnimes;
  //   }
  //   // Api
  //   if (await NetworkService.isConnected) {
  //     try {
  //       final animes = await RequestQueue.instance.enqueue(
  //         () => api.getSeasonAnimes(page: page),
  //       );

  //       // Save dans le cache si page 1
  //       if (page == 1) {
  //         AnimeSectionsProvider.instance.saveSection(section, animes);
  //       }
  //       return animes;
  //     } catch (e) {
  //       debugPrint("[AnimeRepository] getAiringAnimes: $e");
  //     }
  //   }
  //   return [];
  // }

  // Future<List<Anime>> getMostLikedAnimes({int page = 1}) async {
  //   final section = AnimeSections.mostLiked;
  //   if (page == 1) {
  //     // Database
  //     final cachedAnimes = await AnimeSectionsProvider.instance.getAnimes(
  //       section,
  //     );
  //     if (cachedAnimes.isNotEmpty) return cachedAnimes;
  //   }
  //   // Api
  //   if (await NetworkService.isConnected) {
  //     try {
  //       final animes = await RequestQueue.instance.enqueue(
  //         () => api.getTopAnime(page: page, filter: "favorite"),
  //       );

  //       // Save dans le cache si page 1
  //       if (page == 1) {
  //         AnimeSectionsProvider.instance.saveSection(section, animes);
  //       }
  //       return animes;
  //     } catch (e) {
  //       debugPrint("[AnimeRepository] getMostLikedAnimes: $e");
  //     }
  //   }

  //   return [];
  // }
}
