import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/manga_repository_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/views/manga_info_view.dart';

class MangaViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  List<Manga> popular = [];
  List<Manga> publishing = [];
  List<Manga> mostLiked = [];

  int _popularPage = 1;
  int _publishingPage = 1;
  int _mostLikedPage = 1;

  bool _isLoadingPopular = false;
  bool _isLoadingPublishing = false;
  bool _isLoadingMostLiked = false;

  bool _hasMorePopular = true;
  bool _hasMorePublishing = true;
  bool _hasMoreMostLiked = true;

  MangaViewModel() {
    _init();
  }

  void _init() async {
    await fetchPopular();
    await fetchPublishing();
    await fetchMostLiked();
  }

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

  void openMangaPage(BuildContext context, Manga manga) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MangaInfoView(manga)),
    );
  }
}
