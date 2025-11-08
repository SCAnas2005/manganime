import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/JikanService.dart';

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
}
