import 'package:hive/hive.dart';

class LikeStorage {
  static const String LIKES_BOX_KEY = "likes_box";
  static const String LIKED_ANIMES_KEY = "liked_animes";
  static const String LIKED_MANGAS_KEY = "liked_mangas";
  // <<<<<<< HEAD
  //   static final Box<List> _box = Hive.box<List>("likes_box");

  //   static List<int> getIdAnimeLiked() {
  //     final list = _box.get("liked_animes", defaultValue: [])!;
  //     return List<int>.from(list);
  //   }

  //   static Future<void> toggleAnimeLike(int animeId) async {
  //     final liked = getIdAnimeLiked();

  //     if (liked.contains(animeId)) {
  //       liked.remove(animeId);
  //     } else {
  //       liked.add(animeId);
  //     }

  //     await _box.put(LIKED_ANIMES_KEY, liked);
  //   }

  //   static bool isLiked(int animeId) {
  //     return getIdAnimeLiked().contains(animeId);
  //   }
  // =======

  static final Box<List> _box = Hive.box<List>("likes_box");

  static void init() async {
    await Hive.openBox<List>(LIKES_BOX_KEY);
  }

  static List<int> _getIds(String key) {
    final list = _box.get(key, defaultValue: [])!;
    return List<int>.from(list);
  }

  static Future<void> _toggleId(String key, int id) async {
    final liked = _getIds(key);

    if (liked.contains(id)) {
      liked.remove(id);
    } else {
      liked.add(id);
    }

    await _box.put(key, liked);
  }

  static bool _isLiked(String key, int id) {
    return _getIds(key).contains(id);
  }

  static List<int> getIdAnimeLiked() => _getIds(LIKED_ANIMES_KEY);

  static Future<void> toggleAnimeLike(int animeId) =>
      _toggleId(LIKED_ANIMES_KEY, animeId);

  static bool isAnimeLiked(int animeId) => _isLiked(LIKED_ANIMES_KEY, animeId);

  static List<int> getIdMangaLiked() => _getIds(LIKED_MANGAS_KEY);

  static Future<void> toggleMangaLike(int mangaId) =>
      _toggleId(LIKED_MANGAS_KEY, mangaId);

  static bool isMangaLiked(int mangaId) => _isLiked(LIKED_MANGAS_KEY, mangaId);
}
