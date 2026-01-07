import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';

class SearchViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();
  List<Anime> results = [];

  // Le Timer pour le Debounce
  Timer? _debounce;

  // Pour éviter de relancer la recherche si le texte n'a pas changé
  String _lastQuery = "";

  /// Cette méthode est appelée par l'UI à chaque frappe
  void onSearchTextChanged(String query) {
    // 1. SI un timer tourne déjà (l'utilisateur tape encore), on l'annule !
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. On lance un nouveau timer. Si l'utilisateur ne tape rien
    // pendant 500ms, ALORS on exécutera le code à l'intérieur.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Petite sécurité : si le texte est le même, on ne fait rien
      if (query == _lastQuery) return;

      _lastQuery = query;

      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        searchEmpty();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    // 3. On passe par la RequestQueue pour la sécurité API
    try {
      final newResults = await RequestQueue.instance.enqueue(() {
        return _service.searchAnime(query: query);
      });

      results = newResults;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Search: $e");
    }
  }

  Future<void> searchEmpty() async {
    try {
      // Même pour le top anime, on passe par la queue
      results = await RequestQueue.instance.enqueue(() {
        return _service.getTopAnime();
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Empty Search: $e");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Toujours nettoyer les timers
    super.dispose();
  }
}
