import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';

class SearchViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();
  List<Anime> results = [];

  Future<void> search(String query) async {
    results = await RequestQueue.instance.enqueue(() {
      return _service.search(query: query);
    });
    notifyListeners();
  }

  Future<void> searchEmpty(String query) async {
    results = await RequestQueue.instance.enqueue(() {
      return _service.getTopAnime();
    });
    notifyListeners();
  }
}
