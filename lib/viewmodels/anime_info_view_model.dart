import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_repository_provider.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/services/translator.dart';

class AnimeInfoViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  Anime? anime;
  String translatedSynopsis = '';
  bool isLoading = false;
  bool hasError = false;

  bool isLiked = false;
  bool showLikeAnimation = false;

  Future<void> loadAnimeDetail(int animeId) async {
    isLoading = true;
    hasError = false;

    try {
      anime = await AnimeRepository(api: _service).getAnime(animeId);
      translatedSynopsis =
          anime?.synopsis ??
          ""; //await Translator.translateToFrench(anime!.synopsis);
    } catch (e) {
      hasError = true;
      debugPrint("[AnimeInfoViewModel] loadAnimeDetail error: $e");
    }

    isLiked = LikeStorage.getIdAnimeLiked().contains(anime?.id);
    isLoading = false;
    notifyListeners();
  }

  void toggleLike({bool? value}) {
    isLiked = value ?? !isLiked;
    notifyListeners();
  }

  void likeAnimeOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
    showLikeAnimation = true;
    toggleLike();

    Future.delayed(duration, () {
      showLikeAnimation = false;
      notifyListeners();
    });
  }
}
