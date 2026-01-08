import 'package:flutter_application_1/models/manga.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MangaCache {
  static final MangaCache instance = MangaCache();

  // ignore: non_constant_identifier_names
  static final String MANGA_CACHE_KEY = "manga_cache";
  final Map<int, Manga> _memory = {}; // cache rapide (RAM)
  late final Box _box; // cache persistant

  get memoryCache => _memory;
  get box => _box;

  Future<void> init() async {
    _box = await Hive.openBox(MANGA_CACHE_KEY);
  }

  Future<void> populate(List<Manga> mangas) async {
    if (mangas.isEmpty) return;

    for (var manga in mangas) {
      await save(manga);
    }
  }

  /// Récupère un manga déjà en cache (RAM ou Hive)
  Manga? get(int id) {
    // 1. Cache mémoire
    if (_memory.containsKey(id)) {
      return _memory[id];
    }

    // 2. Cache local (Hive)
    final data = _box.get(id);
    if (data != null) {
      final manga = Manga.fromJson(Map<String, dynamic>.from(data));
      _memory[id] = manga; // on recharge en mémoire
      return manga;
    }

    // 3. Pas trouvé
    return null;
  }

  /// Sauvegarde un manga dans le cache mémoire + Hive
  Future<void> save(Manga manga) async {
    final id = manga.id;
    // 1. En mémoire
    _memory[id] = manga;
    // 2. En local
    await _box.put(id, manga.toJson());
  }

  /// Vérifie si le manga est en cache
  bool exists(int id) {
    return _memory.containsKey(id) || _box.containsKey(id);
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
}
