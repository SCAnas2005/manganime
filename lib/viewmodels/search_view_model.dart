import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/models/anime_enums.dart';


class SearchViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();
  List<Anime> results = [];
    String _lastQuery = "";

  Future<void> search(String query) async {
    _lastQuery = query;
    results = await _service.search(
      query: query);
    notifyListeners();
  }

 Future<void> searchEmpty(String query, {required String filter}) async {
  _lastQuery = query;

  switch (filter) {
    case 'Popularité':
      results = await _service.getTopAnime(filter: 'bypopularity');
      break;
    case 'Note':
      results = await _service.getTopAnime();
      break;
    case 'Favoris':
      results = await _service.getTopAnime(filter: 'favorite');
      break;
  
  }

  notifyListeners();
}



}
