import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import '../providers/like_storage.dart';

class FavoriteAnimeViewModel extends ChangeNotifier {
  final JikanService _jikan = JikanService();
  List<AnimeDetail> favoris = [];
  bool isLoading = true;

  FavoriteAnimeViewModel() {
    loadFavoris();
  }

  Future<void> loadFavoris() async {
    isLoading = true;
    notifyListeners();

    final ids = LikeStorage.getIdAnimeLiked();
    final List<AnimeDetail> loaded = [];

    for (int id in ids) {
      // test pour voir la latence dans la page fav
      //await Future.delayed(const Duration(milliseconds: 200));
      final anime = await _jikan.getFullDetailAnime(id);
      loaded.add(anime);
    }

    favoris = loaded;
    isLoading = false;
    notifyListeners();
  }

  void removeFavoris(int id) {
    LikeStorage.toggleAnimeLike(id);
    favoris.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
