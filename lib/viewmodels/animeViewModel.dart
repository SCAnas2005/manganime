import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/JikanService.dart';
import 'package:flutter_application_1/views/AnimeInfo.dart';

class AnimeViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  List<Anime> animes = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  AnimeViewModel() {
    fetchAnimes(); // Charger dès la création du ViewModel
  }

  Future<void> fetchAnimes() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newAnimes = await _service.getTopAnime(page: _currentPage);

      if (newAnimes.isEmpty) {
        _hasMore = false;
      } else {
        animes.addAll(newAnimes);
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Erreur: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void refresh() {
    animes.clear();
    _currentPage = 1;
    _hasMore = true;
    fetchAnimes();
  }

  void openAnimePage(BuildContext context, Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimeInfoView(anime)),
    );
  }
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
