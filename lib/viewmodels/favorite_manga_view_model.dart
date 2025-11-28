import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/manga_detail.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import '../providers/like_storage.dart';

class FavoriteMangaViewModel extends ChangeNotifier {
  final JikanService _jikan = JikanService();
  List<MangaDetail> favoris = [];
  bool isLoading = true;

  FavoriteMangaViewModel() {
    loadFavoris();
  }

  Future<void> loadFavoris() async {
    isLoading = true;
    notifyListeners();

    final ids = LikeStorage.getIdMangaLiked();
    final List<MangaDetail> loaded = [];

    for (int id in ids) {
      // test pour voir la latence dans la page fav
      //await Future.delayed(const Duration(milliseconds: 200));
      final manga = await _jikan.getFullDetailManga(id);
      loaded.add(manga);
    }

    favoris = loaded;
    isLoading = false;
    notifyListeners();
  }

  void removeFavoris(int id) {
    LikeStorage.toggleMangaLike(id);
    favoris.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
