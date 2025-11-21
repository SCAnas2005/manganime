import 'package:flutter/material.dart';
import '../models/favorite_item.dart';
import '../models/anime.dart';
import '../providers/like_storage.dart';

class FavoriteViewModel extends ChangeNotifier {
  final List<Anime> allAnimes;

  FavoriteViewModel({required this.allAnimes});

  List<FavoriteItem> _favoriteAnimes = [];
  bool _isLoading = false;

  List<FavoriteItem> get favoriteAnimes => List.unmodifiable(_favoriteAnimes);
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _setLoading(true);

    final likedIds = LikeStorage.getIdAnimeLiked();
    _favoriteAnimes = allAnimes
        .where((anime) => likedIds.contains(anime.id))
        .map(
          (anime) => FavoriteItem(
            id: anime.id,
            title: anime.title,
            imageUrl: anime.imageUrl,
            score: anime.score,
            status: anime.status,
          ),
        )
        .toList();

    _setLoading(false);
  }

  Future<void> removeFavorite(FavoriteItem item) async {
    _favoriteAnimes.removeWhere((f) => f.id == item.id);
    await LikeStorage.toggleAnimeLike(item.id);
    notifyListeners();
  }

  bool isEmpty() => _favoriteAnimes.isEmpty;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
