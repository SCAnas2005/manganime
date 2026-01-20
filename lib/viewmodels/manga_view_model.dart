import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/global_manga_favorites_provider.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/views/manga_info_view.dart';

/// ViewModel principal pour la gestion des listes de mangas.
///
/// Il centralise l'état de 4 catégories principales :
/// 1. [popular] : Les mangas les plus populaires (tous temps confondus).
/// 2. [publishing] : Les mangas actuellement en cours de publication.
/// 3. [mostLiked] : Les mangas les mieux notés par la communauté.
/// 4. [forYou] : Recommandations personnalisées basées sur les likes.
///
/// Il gère la pagination automatique (infinite scroll) pour chaque catégorie.
class MangaViewModel extends ChangeNotifier {
  List<Manga> popular = [];
  List<Manga> publishing = [];
  List<Manga> mostLiked = [];

  List<Manga> forYou = [];

  int _popularPage = 1;
  int _publishingPage = 1;
  int _mostLikedPage = 1;

  int _forYouPage = 1;

  bool _isLoadingPopular = false;
  bool _isLoadingPublishing = false;
  bool _isLoadingMostLiked = false;

  bool _isLoadingForYou = false;

  /// Getters d'état de chargement pour l'UI (Spinners).
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingPublishing => _isLoadingPublishing;
  bool get isLoadingMostLiked => _isLoadingMostLiked;

  bool get isLoadingForYou => _isLoadingForYou;

  bool _hasMorePopular = true;
  bool _hasMorePublishing = true;
  bool _hasMoreMostLiked = true;

  bool _hasMoreForYou = true;

  /// Getters de pagination : true s'il reste des pages à charger.
  bool get hasMorePopular => _hasMorePopular;
  bool get hasMorePublishing => _hasMorePublishing;
  bool get hasMoreMostLiked => _hasMoreMostLiked;

  bool get hasMoreForYou => _hasMoreForYou;

  MangaViewModel() {
    _init();
  }

  /// Initialise le ViewModel en lançant les requêtes pour les 3 onglets principaux.
  void _init() async {
    await fetchPopular();
    await fetchPublishing();
    await fetchMostLiked();
  }

  /// Récupère la page suivante des mangas les plus populaires.
  ///
  /// Utilise un mécanisme de [retries] pour réessayer jusqu'à 3 fois en cas d'erreur réseau.
  Future<void> fetchPopular({int retries = 3}) async {
    if (_isLoadingPopular || !_hasMorePopular) return;

    _isLoadingPopular = true;
    notifyListeners();

    try {
      final mangas = await MangaRepository(
        api: JikanService(),
      ).getPopularMangas(page: _popularPage);

      if (mangas.isEmpty) {
        _hasMorePopular = false;
      } else {
        popular.addAll(mangas);
        _popularPage++;
      }
    } catch (e) {
      debugPrint('Erreur fetchPopularManga: $e');

      if (retries > 0) {
        await Future.delayed(Duration(seconds: 1));
        return await fetchPopular();
      }
    }

    _isLoadingPopular = false;
    notifyListeners();
  }

  /// Récupère la page suivante des mangas en cours de publication.
  Future<void> fetchPublishing({int retries = 3}) async {
    if (_isLoadingPublishing || !_hasMorePublishing) return;

    _isLoadingPublishing = true;
    notifyListeners();

    try {
      final mangas = await MangaRepository(
        api: JikanService(),
      ).getPublishingMangas(page: _publishingPage);

      if (mangas.isEmpty) {
        _hasMorePublishing = false;
      } else {
        publishing.addAll(mangas);
        _publishingPage++;
      }
    } catch (e) {
      debugPrint('Erreur fetchPublishingManga: $e');

      if (retries > 0) {
        await Future.delayed(Duration(seconds: 1));
        return await fetchPublishing();
      }
    }

    _isLoadingPublishing = false;
    notifyListeners();
  }

  /// Récupère la page suivante des mangas les mieux notés.
  Future<void> fetchMostLiked({int retries = 3}) async {
    if (_isLoadingMostLiked || !_hasMoreMostLiked) return;

    _isLoadingMostLiked = true;
    notifyListeners();

    try {
      final mangas = await MangaRepository(
        api: JikanService(),
      ).getMostLikedMangas(page: _mostLikedPage);

      if (mangas.isEmpty) {
        _hasMoreMostLiked = false;
      } else {
        mostLiked.addAll(mangas);
        _mostLikedPage++;
      }
    } catch (e) {
      debugPrint('Erreur fetchMostLikedManga: $e');

      if (retries > 0) {
        await Future.delayed(Duration(seconds: 1));
        return await fetchMostLiked();
      }
    }

    _isLoadingMostLiked = false;
    notifyListeners();
  }

  // ---------------- FOR YOU ----------------

  /// Charge les recommandations personnalisées.
  ///
  /// Nécessite [GlobalMangaFavoritesProvider] pour analyser les goûts de l'utilisateur.
  Future<void> fetchForYou(GlobalMangaFavoritesProvider provider) async {
    try {
      var mangas = await MangaRepository(
        api: JikanService(),
      ).getForYouManga(provider, page: _forYouPage);

      if (mangas.isEmpty) {
        _hasMoreForYou = false;
      } else {
        forYou.addAll(mangas);
        _forYouPage++;
      }
    } catch (e) {
      debugPrint("Erreur de fetchForYou : $e");
    }

    _isLoadingForYou = false;
    notifyListeners();
  }

  /// Rafraîchit manuellement l'onglet "Pour toi".
  ///
  /// Vide la liste et notifie l'UI immédiatement pour éviter les erreurs d'index,
  /// puis relance la recherche depuis la page 1.
  Future<void> refreshForYou(GlobalMangaFavoritesProvider provider) async {
    forYou.clear();
    notifyListeners();
    _forYouPage = 1;
    _hasMoreForYou = true;
    await fetchForYou(provider);
  }

  /// Helper de navigation vers la page de détails d'un manga.
  void openMangaPage(BuildContext context, Manga manga) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MangaInfoView(manga)),
    );
  }
}
