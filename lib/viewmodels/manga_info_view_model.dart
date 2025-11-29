import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga_detail.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/services/translator.dart';

class MangaInfoViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  MangaDetail? mangaDetail;
  String translatedSynopsis = '';
  bool isLoading = false;
  bool hasError = false;
  bool isLiked = false;
  bool showLikeAnimation = false;

  Future<void> loadMangaDetail(int mangaId) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      mangaDetail = await _service.getFullDetailManga(mangaId);
      translatedSynopsis = await Translator.translateToFrench(
        mangaDetail?.synopsis ?? '',
      );
    } catch (e) {
      hasError = true;
    }

    if (mangaDetail != null) {
      isLiked = LikeStorage.isMangaLiked(mangaDetail!.id);
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleLike({bool? value}) {
    isLiked = value ?? !isLiked;
    notifyListeners();
  }

  void likeMangaOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
    showLikeAnimation = true;
    toggleLike();

    Future.delayed(duration, () {
      showLikeAnimation = false;
      notifyListeners();
    });
  }
}
