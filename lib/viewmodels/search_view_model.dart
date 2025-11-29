import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
// import 'package:flutter_application_1/widgets/Search.dart';

class SearchViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();
  List<Anime> results = [];

  Future<void> search(String query) async {
    results = await _service.searchAnime(query: query);
    notifyListeners();
  }

  Future<void> searchEmpty(String query) async {
    results = await _service.getTopAnime();
    notifyListeners();
  }
}
