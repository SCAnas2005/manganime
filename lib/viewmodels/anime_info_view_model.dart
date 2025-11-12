import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/services/JikanService.dart';
import 'package:flutter_application_1/services/translator.dart';

class AnimeInfoViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  AnimeDetail? animeDetail;
  String translatedSynopsis = '';
  bool isLoading = false;
  bool hasError = false;

  bool isLiked = false;
  bool showLikeAnimation = false;

  Future<void> loadAnimeDetail(int animeId) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      animeDetail = await _service.getFullDetailAnime(animeId);
      translatedSynopsis = await Translator.translateToFrench(
        animeDetail!.synopsis,
      );
    } catch (e) {
      hasError = true;
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleLike() {
    isLiked = !isLiked;
    notifyListeners();
  }

  void likeAnimeOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
    showLikeAnimation = true;
    notifyListeners();
    isLiked = true;

    Future.delayed(duration, () {
      showLikeAnimation = false;
      notifyListeners();
    });
  }
}
