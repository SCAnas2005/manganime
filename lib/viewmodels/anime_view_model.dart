import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/JikanService.dart';
import 'package:flutter_application_1/views/anime_info_view.dart';

class AnimeViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  List<Anime> popular = [];
  List<Anime> airing = [];
  List<Anime> mostLiked = [];

  int _popularPage = 1;
  int _airingPage = 1;
  int _mostLikedPage = 1;

  bool _isLoadingPopular = false;
  bool _isLoadingAiring = false;
  bool _isLoadingMostLiked = false;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingAiring => _isLoadingAiring;
  bool get isLoadingMostLiked => _isLoadingMostLiked;

  bool _hasMorePopular = true;
  bool _hasMoreAiring = true;
  bool _hasMoreMostLiked = true;

  bool get hasMorePopular => _hasMorePopular;
  bool get hasMoreAiring => _hasMoreAiring;
  bool get hasMoreMostLiked => _hasMoreMostLiked;

  AnimeViewModel() {
    fetchPopular();
    fetchAiring();
    fetchMostLiked();
  }

  // ---------------- POPULAR ----------------
  Future<void> fetchPopular() async {
    if (_isLoadingPopular || !_hasMorePopular) return;

    _isLoadingPopular = true;
    notifyListeners();

    try {
      final newAnimes = await _service.getTopAnime(
        page: _popularPage,
        filter: "bypopularity",
      );
      if (newAnimes.isEmpty) {
        _hasMorePopular = false;
      } else {
        popular.addAll(newAnimes);
        _popularPage++;
      }
    } catch (e) {
      debugPrint('Erreur fetchPopular: $e');
    }

    _isLoadingPopular = false;
    notifyListeners();
  }

  void refreshPopular() {
    popular.clear();
    _popularPage = 1;
    _hasMorePopular = true;
    fetchPopular();
  }

  // ---------------- AIRING ----------------
  Future<void> fetchAiring() async {
    if (_isLoadingAiring || !_hasMoreAiring) return;

    _isLoadingAiring = true;
    notifyListeners();

    try {
      final newAnimes = await _service.getTopAnime(
        page: _airingPage,
        season: "winter",
        year: 2025,
        filter: "airing",
      );

      if (newAnimes.isEmpty) {
        _hasMoreAiring = false;
      } else {
        airing.addAll(newAnimes);
        _airingPage++;
      }
    } catch (e) {
      debugPrint('Erreur fetchAiring: $e');
    }

    _isLoadingAiring = false;
    notifyListeners();
  }

  void refreshAiring() {
    airing.clear();
    _airingPage = 1;
    _hasMoreAiring = true;
    fetchAiring();
  }

  // ---------------- MOST LIKED ----------------
  Future<void> fetchMostLiked() async {
    if (_isLoadingMostLiked || !_hasMoreMostLiked) return;

    _isLoadingMostLiked = true;
    notifyListeners();

    try {
      final newAnimes = await _service.getTopAnime(
        page: _mostLikedPage,
        filter: "favorite",
      );
      if (newAnimes.isEmpty) {
        _hasMoreMostLiked = false;
      } else {
        mostLiked.addAll(newAnimes);
        _mostLikedPage++;
      }
    } catch (e) {
      debugPrint('Erreur fetchMostLiked: $e');
    }

    _isLoadingMostLiked = false;
    notifyListeners();
  }

  void refreshMostLiked() {
    mostLiked.clear();
    _mostLikedPage = 1;
    _hasMoreMostLiked = true;
    fetchMostLiked();
  }

  // ---------------- NAVIGATION ----------------
  void openAnimePage(BuildContext context, Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimeInfoView(anime)),
    );
  }

  // void toggleLike() {
  //   isLiked = !isLiked;
  //   notifyListeners();
  // }

  // void likeAnimeOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
  //   isLiked = true;
  //   notifyListeners();

  //   Future.delayed(duration, () {
  //     isLiked = false;
  //     notifyListeners();
  //   });
  // }
}

// class AnimeViewModel extends ChangeNotifier {
//   final JikanService service = JikanService();

//   List<Anime> popular = [];
//   List<Anime> trending = [];
//   List<Anime> mostViewed = [];
//   bool isLoading = false;

//   AnimeViewModel() {
//     fetchAll();
//   }

//   Future<void> fetchAll() async {
//     isLoading = true;
//     notifyListeners();

//     popular = await service.getTopAnime(page: 1);
//     trending = await service.getTopAnime(page: 2);
//     mostViewed = await service.getTopAnime(page: 3);

//     isLoading = false;
//     notifyListeners();
//   }
// }
