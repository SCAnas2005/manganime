import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/views/anime_info_view.dart';

/// ViewModel principal pour la gestion des listes d'animes.
///
/// Il centralise l'état de 4 catégories principales :
/// 1. [popular] : Les animes populaires du moment.
/// 2. [airing] : Les animes en cours de diffusion.
/// 3. [mostLiked] : Les classiques les mieux notés.
/// 4. [forYou] : Recommandations personnalisées (Cocktail).
///
/// Il gère également la pagination infinie et les états de chargement pour chaque liste.
class AnimeViewModel extends ChangeNotifier {
  List<Anime> popular = [];
  List<Anime> airing = [];
  List<Anime> mostLiked = [];

  List<Anime> forYou = [];

  int _popularPage = 1;
  int _airingPage = 1;
  int _mostLikedPage = 1;

  int _forYouPage = 1;

  bool _isLoadingPopular = false;
  bool _isLoadingAiring = false;
  bool _isLoadingMostLiked = false;

  bool _isLoadingForYou = false;

  /// Getters pour savoir si une section spécifique est en train de charger.
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingAiring => _isLoadingAiring;
  bool get isLoadingMostLiked => _isLoadingMostLiked;

  bool get isLoadingForYou => _isLoadingForYou;

  bool _hasMorePopular = true;
  bool _hasMoreAiring = true;
  bool _hasMoreMostLiked = true;

  bool _hasMoreForYou = true;

  /// Getters pour savoir s'il reste des pages à charger (Pagination).
  bool get hasMorePopular => _hasMorePopular;
  bool get hasMoreAiring => _hasMoreAiring;
  bool get hasMoreMostLiked => _hasMoreMostLiked;

  bool get hasMoreForYou => _hasMoreForYou;

  AnimeViewModel() {
    _init();
  }

  /// Initialise le ViewModel en lançant les requêtes pour les 3 onglets principaux.
  Future<void> _init() async {
    await fetchPopular();
    await fetchAiring();
    await fetchMostLiked();
  }

  // ---------------- POPULAR ----------------

  /// Récupère la page suivante des animes populaires.
  ///
  /// Inclut un mécanisme de [retries] en cas d'échec réseau.
  Future<void> fetchPopular({int retries = 3}) async {
    if (_isLoadingPopular || !_hasMorePopular) return;

    _isLoadingPopular = true;
    bool hasNewItems = true;

    try {
      final newAnimes = await AnimeRepository(
        api: JikanService(),
      ).getPopularAnimes(page: _popularPage);

      if (newAnimes.isEmpty) {
        _hasMorePopular = false;
      } else {
        popular.addAll(newAnimes);
        _popularPage++;
        hasNewItems = true;
      }
    } catch (e) {
      debugPrint('Erreur fetchPopular: $e');

      if (retries > 0) {
        await Future.delayed(Duration(seconds: 1));
        return await fetchPopular();
      }
    }

    _isLoadingPopular = false;
    if (hasNewItems) notifyListeners();
  }

  /// Réinitialise et recharge la liste des populaires (Pull-to-refresh).
  void refreshPopular() {
    popular.clear();
    _popularPage = 1;
    _hasMorePopular = true;
    fetchPopular();
  }

  // ---------------- AIRING ----------------

  /// Récupère la page suivante des animes en cours de diffusion.
  Future<void> fetchAiring({int retries = 3}) async {
    if (_isLoadingAiring || !_hasMoreAiring) return;

    _isLoadingAiring = true;
    bool hasNewItems = false;

    try {
      final newAnimes = await AnimeRepository(
        api: JikanService(),
      ).getAiringAnimes(page: _airingPage);

      if (newAnimes.isEmpty) {
        _hasMoreAiring = false;
      } else {
        airing.addAll(newAnimes);
        _airingPage++;
        hasNewItems = true;
      }
    } catch (e) {
      debugPrint('Erreur fetchAiring: $e');

      if (retries > 0) {
        debugPrint('Retry fetchMostLiked, retries left: ${retries - 1}');
        await Future.delayed(Duration(seconds: 1));
        return await fetchAiring();
      }
    }

    _isLoadingAiring = false;
    if (hasNewItems) notifyListeners();
  }

  /// Réinitialise et recharge la liste des animes en cours.
  void refreshAiring() {
    airing.clear();
    _airingPage = 1;
    _hasMoreAiring = true;
    fetchAiring();
  }

  // ---------------- MOST LIKED ----------------

  /// Récupère la page suivante des animes les mieux notés.
  Future<void> fetchMostLiked({int retries = 3}) async {
    if (_isLoadingMostLiked || !_hasMoreMostLiked) return;

    _isLoadingMostLiked = true;
    bool hasNewItems = false;

    try {
      final newAnimes = await AnimeRepository(
        api: JikanService(),
      ).getMostLikedAnimes(page: _mostLikedPage);
      if (newAnimes.isEmpty) {
        _hasMoreMostLiked = false;
      } else {
        mostLiked.addAll(newAnimes);
        _mostLikedPage++;
        hasNewItems = true;
      }
    } catch (e) {
      debugPrint('Erreur fetchMostLiked: $e');

      if (retries > 0) {
        debugPrint('Retry fetchMostLiked, retries left: ${retries - 1}');
        await Future.delayed(Duration(seconds: 1));
        await fetchMostLiked();
      }
    }

    _isLoadingMostLiked = false;
    if (hasNewItems) notifyListeners();
  }

  /// Réinitialise et recharge la liste des mieux notés.
  void refreshMostLiked() {
    mostLiked.clear();
    _mostLikedPage = 1;
    _hasMoreMostLiked = true;
    fetchMostLiked();
  }

  // ---------------- FOR YOU ----------------

  /// Charge les recommandations personnalisées (Algorithme Cocktail).
  ///
  /// Nécessite [GlobalAnimeFavoritesProvider] pour analyser les goûts de l'utilisateur.
  Future<void> fetchForYou(GlobalAnimeFavoritesProvider provider) async {
    // Recherche Api
    try {
      var animes = await AnimeRepository(
        api: JikanService(),
      ).getForYouAnimes(provider, page: _forYouPage);

      if (animes.isEmpty) {
        _hasMoreForYou = false;
      } else {
        forYou.addAll(animes);
        _forYouPage++;
      }
    } catch (e) {
      debugPrint("Erreur de fetchForYou : $e");
    }

    _isLoadingForYou = false;
    notifyListeners();
  }

  /// Rafraîchit manuellement l'onglet "Pour toi".
  /// Vide la liste et notifie l'UI immédiatement pour éviter les erreurs d'index.
  Future<void> refreshForYou(GlobalAnimeFavoritesProvider provider) async {
    forYou.clear();
    notifyListeners();
    _forYouPage = 1;
    _hasMoreForYou = true;
    await fetchForYou(provider);
  }

  // ---------------- NAVIGATION ----------------

  /// Helper pour naviguer vers la page de détails d'un anime.
  void openAnimePage(BuildContext context, Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimeInfoView(anime: anime)),
    );
  }
}
