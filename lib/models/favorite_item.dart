import 'package:flutter_application_1/models/anime.dart';

class FavoriteItem {
  final int id;
  final Map<String, dynamic> data; // réponse Jikan stockée en JSON

  FavoriteItem({required this.id, required this.data});
}
