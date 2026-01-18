import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';



class SearchViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();
  List<Anime> results = [];
  List<Anime> _allResults = [];
  String _lastQuery = "";
  Set<String> _currentSelectedGenres = {};


  // Le Timer pour le Debounce
  Timer? _debounce;

  // Pour éviter de relancer la recherche si le texte n'a pas changé


  /// Cette méthode est appelée par l'UI à chaque frappe
  void onSearchTextChanged(String query, String filter) {
    // 1. SI un timer tourne déjà (l'utilisateur tape encore), on l'annule !
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. On lance un nouveau timer. Si l'utilisateur ne tape rien
    // pendant 500ms, ALORS on exécutera le code à l'intérieur.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Petite sécurité : si le texte est le même, on ne fait rien
      if (query == _lastQuery) return;

      _lastQuery = query;

      if (query.isNotEmpty) {
        _performSearch(query, filter);
      } else {
        searchEmpty(filter: filter);
        _allResults = [];       
      }
    });
  }

  void onFilterChanged(String newFilter) {
  // Si on a une recherche en cours, on la relance avec le nouveau filtre
  if (_lastQuery.isNotEmpty) {
    _performSearch(_lastQuery, newFilter);
  } else {
    // Sinon on recharge la liste vide avec le nouveau filtre
    searchEmpty(filter: newFilter);
  }
}


 Future<void> _performSearch(String query, String filter) async {
  try {
    MediaOrderBy? orderBy;
    SortOrder? sortOrder;

    if (filter == 'date de sortie') {
      orderBy = MediaOrderBy.start_date;
      sortOrder = SortOrder.asc;
    } else if (filter == 'Popularité') {
      orderBy = MediaOrderBy.popularity;
      sortOrder = SortOrder.asc;
    } else if (filter == 'Note') {
      orderBy = MediaOrderBy.score;
      sortOrder = SortOrder.desc; 
    }

    final newResults = await AnimeRepository(
      api: JikanService(),
    ).search(
      query: query,
      orderBy: orderBy,
      sort: sortOrder,
    );

    results = newResults;
    _allResults = newResults;
    _applyGenreFilter();
    notifyListeners();
  } catch (e) {
    debugPrint("Erreur Search: $e");
  }
}
  
  void _applyGenreFilter() {
    if (_currentSelectedGenres.isEmpty) {
      results = List.from(_allResults);
    } else {
      results = _allResults.where((anime) {
        final animeGenres = anime.genres.map((g) => g.name).toSet();
        return _currentSelectedGenres.every((g) => animeGenres.contains(g));
      }).toList();
    }
    notifyListeners();
  }
 

void updateSelectedGenres(Set<String> genres) {
  _currentSelectedGenres = genres;
  _applyGenreFilter();
}


Future<void> searchEmpty({required String filter}) async {
    try {
      MediaOrderBy? orderBy;
      SortOrder? sortOrder;

      // Configuration du tri selon le filtre
      if (filter == 'date de sortie') {
        orderBy = MediaOrderBy.start_date;
        sortOrder = SortOrder.desc;
      } else if (filter == 'Popularité') {
        orderBy = MediaOrderBy.popularity;
        sortOrder = SortOrder.asc;
      } else if (filter == 'Note') {
        orderBy = MediaOrderBy.score;
        sortOrder = SortOrder.desc;
      }
   // Recherche avec query vide mais avec tri
      results = await AnimeRepository(
        api: JikanService(),
      ).search(
        query: "",
        orderBy: orderBy,
        sort: sortOrder,
      );

      _allResults = List.from(results);
      _applyGenreFilter();
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
