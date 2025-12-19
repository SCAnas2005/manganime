import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/providers/anime_path_provider.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/network_service.dart';

class AnimeRepository {
  final ApiService api;

  AnimeRepository({required this.api});

  Future<void> loadAnimes() async {}

  Future<Anime?> getAnime(int id) async {
    // 1. Cache
    var data = await AnimeCache.instance.get(id);
    if (data != null) return data;

    // 2. Base de donnée
    data = await DatabaseProvider.instance.getAnime(id);
    if (data != null) return data;

    if (await NetworkService.isConnected) {
      // 3. API
      final anime = await RequestQueue.instance.enqueue(
        () => api.getFullDetailAnime(id),
      );

      // 3. Sauvegarde
      await AnimeCache.instance.save(anime);

      return anime;
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
}
