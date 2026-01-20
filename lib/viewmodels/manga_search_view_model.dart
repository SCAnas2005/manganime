import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';

/// ViewModel dédié à la gestion de la recherche de Mangas.
///
/// Il implémente plusieurs logiques clés :
/// 1. **Debounce (Anti-rebond)** : Attend que l'utilisateur finisse de taper pour lancer la requête.
/// 2. **Tri API** : Gère les filtres de tri (Popularité, Date, Note) envoyés au serveur.
/// 3. **Filtrage Local** : Gère le filtrage par genres (Action, Aventure, etc.) côté client sur les résultats reçus.
class MangaSearchViewModel extends ChangeNotifier {
  List<Manga> results = [];

  /// Copie de sauvegarde de tous les résultats reçus de l'API.
  /// Utilisée pour restaurer la liste quand on décoche des filtres de genre sans rappeler l'API.
  List<Manga> _allResults = [];

  String _lastQuery = "";
  Set<String> _currentSelectedGenres = {};

  // Le Timer pour le Debounce
  Timer? _debounce;

  // Pour éviter de relancer la recherche si le texte n'a pas changé

  /// Gère la saisie utilisateur avec un mécanisme de **Debounce** (anti-rebond).
  ///
  /// Cette méthode est appelée par l'UI à chaque frappe. Elle attend 500ms de silence
  /// avant de valider la recherche, économisant ainsi les appels API et la batterie.
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

  /// Met à jour le critère de tri principal (Date, Popularité, Note) et relance la recherche.
  void onFilterChanged(String newFilter) {
    // Si on a une recherche en cours, on la relance avec le nouveau filtre
    if (_lastQuery.isNotEmpty) {
      _performSearch(_lastQuery, newFilter);
    } else {
      // Sinon on recharge la liste vide avec le nouveau filtre
      searchEmpty(filter: newFilter);
    }
  }

  /// Exécute la requête API via le [MangaRepository].
  ///
  /// Convertit les chaînes de caractères des filtres (ex: "Popularité") en énumérations
  /// [MediaOrderBy] et [SortOrder] compréhensibles par l'API Jikan.
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

      final newResults = await MangaRepository(
        api: JikanService(),
      ).search(query: query, orderBy: orderBy, sort: sortOrder);

      results = newResults;
      _allResults = newResults;
      _applyGenreFilter();
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur Search: $e");
    }
  }

  /// Applique un filtre local sur les résultats déjà chargés en fonction des genres sélectionnés.
  ///
  /// Cette méthode ne refait pas d'appel API, elle filtre simplement la liste [_allResults].
  void _applyGenreFilter() {
    if (_currentSelectedGenres.isEmpty) {
      results = List.from(_allResults);
    } else {
      results = _allResults.where((manga) {
        final mangaGenres = manga.genres.map((g) => g.name).toSet();
        return _currentSelectedGenres.every((g) => mangaGenres.contains(g));
      }).toList();
    }
    notifyListeners();
  }

  /// Met à jour la liste des genres sélectionnés et rafraîchit l'affichage.
  void updateSelectedGenres(Set<String> genres) {
    _currentSelectedGenres = genres;
    _applyGenreFilter();
  }

  /// Effectue une recherche "par défaut" (sans mot-clé) mais en appliquant les critères de tri.
  ///
  /// Utile pour afficher une liste initiale pertinente (ex: Top Popularité) quand la barre est vide.
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
      results = await MangaRepository(
        api: JikanService(),
      ).search(query: "", orderBy: orderBy, sort: sortOrder);

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
