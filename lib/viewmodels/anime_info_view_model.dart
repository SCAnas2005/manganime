import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/providers/like_storage.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
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

    isLiked = LikeStorage.getIdAnimeLiked().contains(animeDetail?.id);
    isLoading = false;
    notifyListeners();
  }

  void toggleLike({bool? value}) {
    isLiked = value ?? !isLiked;
    if (animeDetail != null) {
      LikeStorage.toggleAnimeLike(animeDetail!.id);
    }
    notifyListeners();
  }

  void likeAnimeOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
    showLikeAnimation = true;
    toggleLike(value: true);

    Future.delayed(duration, () {
      showLikeAnimation = false;
      notifyListeners();
    });
  }
}
