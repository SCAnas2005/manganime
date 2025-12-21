import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/global_anime_favorites_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/providers/user_profile_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/views/anime_info_view.dart';

class AnimeViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

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

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingAiring => _isLoadingAiring;
  bool get isLoadingMostLiked => _isLoadingMostLiked;

  bool get isLoadingForYou => _isLoadingForYou;

  bool _hasMorePopular = true;
  bool _hasMoreAiring = true;
  bool _hasMoreMostLiked = true;

  bool _hasMoreForYou = true;

  bool get hasMorePopular => _hasMorePopular;
  bool get hasMoreAiring => _hasMoreAiring;
  bool get hasMoreMostLiked => _hasMoreMostLiked;

  bool get hasMoreForYou => _hasMoreForYou;

  AnimeViewModel() {
    _init();
  }

  Future<void> _init() async {
    await fetchPopular();
    await fetchAiring();
    await fetchMostLiked();
  }

  // ---------------- POPULAR ----------------
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

  void refreshPopular() {
    popular.clear();
    _popularPage = 1;
    _hasMorePopular = true;
    fetchPopular();
  }

  // ---------------- AIRING ----------------
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

  void refreshAiring() {
    airing.clear();
    _airingPage = 1;
    _hasMoreAiring = true;
    fetchAiring();
  }

  // ---------------- MOST LIKED ----------------
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

  void refreshMostLiked() {
    mostLiked.clear();
    _mostLikedPage = 1;
    _hasMoreMostLiked = true;
    fetchMostLiked();
  }

  // ---------------- FOR YOU    ----------------
  Future<void> fetchForYou(GlobalAnimeFavoritesProvider provider) async {
    debugPrint("Building recommendation algorithm");
    // Récupération des animes liékes
    final liked = provider.loadedFavoriteAnimes;
    debugPrint("Liked animes : $liked");
    // Calcul du profil utilisateur
    final userProfile = UserprofileProvider.fromLikedAnimes(liked);
    debugPrint("User profil built: $userProfile");

    // Le top genres
    final topGenres = userProfile.getTopGenres(3);
    debugPrint(
      "Top genres: ${topGenres.first}, ${topGenres[1]}, ${topGenres[2]}",
    );

    // Recherche Api
    try {
      var animes = await RequestQueue.instance.enqueue(
        () => _service.search(page: _forYouPage, query: "", genres: topGenres),
      );
      debugPrint("fetchForYou animes count : ${animes.length}");

      debugPrint("Removing liked animes from suggestions");
      animes = animes.where((a) => !liked.contains(a)).toList();

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

  void refreshForYou(GlobalAnimeFavoritesProvider provider) {
    forYou.clear();
    _forYouPage = 1;
    _hasMoreForYou = true;
    fetchForYou(provider);
  }

  // ---------------- NAVIGATION ----------------
  void openAnimePage(BuildContext context, Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimeInfoView(anime: anime)),
    );
  }
}
