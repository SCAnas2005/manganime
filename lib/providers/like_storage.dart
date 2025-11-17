import 'package:hive/hive.dart';

class LikeStorage {
  static const String LIKED_ANIMES_KEY = "liked_animes";
  static final Box<List> _box = Hive.box<List>("likes_box");

  static List<int> getIdAnimeLiked() {
    final list = _box.get("liked_animes", defaultValue: [])!;
    return List<int>.from(list);
  }

  static Future<void> toggleAnimeLike(int animeId) async {
    final liked = getIdAnimeLiked();

    if (liked.contains(animeId)) {
      liked.remove(animeId);
    } else {
      liked.add(animeId);
    }

    await _box.put(LIKED_ANIMES_KEY, liked);
  }

  static bool isLiked(int animeId) {
    return getIdAnimeLiked().contains(animeId);
  }
}
