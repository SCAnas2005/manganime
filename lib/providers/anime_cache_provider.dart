// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnimeCache {
  static final AnimeCache instance = AnimeCache();

  static final String ANIME_CACHE_KEY = "anime_cache";
  final Map<int, Anime> _memory = {}; // cache rapide (RAM)
  late final Box _box; // cache persistant

  get memoryCache => _memory;
  get box => _box;

  Future<void> init() async {
    _box = await Hive.openBox(ANIME_CACHE_KEY);
  }

  Future<void> populate(List<Anime> animes) async {
    if (animes.isEmpty) return;

    for (var anime in animes) {
      await save(anime);
    }
  }

  /// Récupère un anime déjà en cache (RAM ou Hive)
  Future<Anime?> get(int id) async {
    // 1. Cache mémoire
    if (_memory.containsKey(id)) {
      return _memory[id];
    }

    // 2. Cache local (Hive)
    final data = _box.get(id);
    if (data != null) {
      final anime = Anime.fromJson(Map<String, dynamic>.from(data));
      debugPrint("(AnimeCache) get: loading anime ${anime.id}");
      _memory[id] = anime; // on recharge en mémoire
      return anime;
    }

    // 3. Pas trouvé
    return null;
  }

  /// Sauvegarde un anime dans le cache mémoire + Hive
  Future<void> save(Anime anime) async {
    final id = anime.id;
    // 1. En mémoire
    _memory[id] = anime;
    // 2. En local
    await _box.put(id, anime.toJson());
  }

  /// Vérifie si l’anime est en cache
  bool exists(int id) {
    return _box.containsKey(id);
  }

  /// Vide toute la cache (rarement utile)
  Future<void> clear() async {
    clearMemory();
    await clearLocalCache();
  }

  void clearMemory() {
    _memory.clear();
  }

  Future<void> clearLocalCache() async {
    await _box.clear();
  }

  Future<void> update(Anime anime) async {
    if (exists(anime.id)) {
      await save(anime);
    }
  }

  /// Met à jour tous les animes déjà en cache
  Future<void> updateCache({String? defaultSynopsis}) async {
    AnimeRepository repo = AnimeRepository(api: JikanService());
    // Parcours de tous les items dans Hive
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data == null) continue;

      final anime = Anime.fromJson(Map<String, dynamic>.from(data));

      // if (anime.synopsis.isNotEmpty) return;

      // Database
      Anime? updatedAnime = await repo.getAnimeFromDatabase(anime.id);
      // Api
      updatedAnime = updatedAnime ?? await repo.getAnimeFromService(anime.id);

      // Sauvegarde en mémoire et dans Hive
      if (updatedAnime != null) {
        update(updatedAnime);
        await ImageSyncService.instance.scheduleDownload<Anime>(updatedAnime);
        debugPrint(
          "Cache mis à jour avec succès pour id:${updatedAnime.id} ${updatedAnime.title}",
        );
      }
    }
  }
}
