import 'package:flutter_application_1/models/anime.dart';

class FavoriteItem {
  final int id;
  final String title;
  final String imageUrl;
  final double? score;
  final String status;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.score,
    required this.status,
  });

  Anime toAnime() {
    return Anime(
      id: id,
      title: title,
      imageUrl: imageUrl,
      score: score,
      status: status,
    );
  }
}
