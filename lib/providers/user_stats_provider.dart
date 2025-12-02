import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class UserStatsProvider {
  static const String STATS_BOX_KEY = "stats_box";

  static const ANIME_VIEWS_KEY = "anime_views";
  static const MANGA_VIEWS_KEY = "manga_views";

  static final Box<List> _box = Hive.box<List>(STATS_BOX_KEY);

  // Initialisation
  static Future<void> init() async {
    await Hive.openBox<List>(STATS_BOX_KEY);
  }

  // GETTERS

  static int _getViewsCount(String key) {
    final list = _box.get(key, defaultValue: [])!;
    return list.length;
  }

  static int getAnimeViewsCount() {
    return _getViewsCount(ANIME_VIEWS_KEY);
  }

  static int getMangaViewsCount() {
    return _getViewsCount(MANGA_VIEWS_KEY);
  }

  static int getAllViewsCount() {
    return getAnimeViewsCount() + getMangaViewsCount();
  }

  static ValueListenable<Box<List>> getViewsListenable() {
    return _box.listenable();
  }

  // SETTERS
  static void _addView(String key, int id) {
    final list = List<int>.from(_box.get(key, defaultValue: [])!);
    if (!list.contains(id)) {
      list.add(id);
    }

    _box.put(key, list);
  }

  static void addAnimeView(int animeId) {
    _addView(ANIME_VIEWS_KEY, animeId);
  }

  static void addMangaView(int mangaId) {
    _addView(MANGA_VIEWS_KEY, mangaId);
  }
}
