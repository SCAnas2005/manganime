import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';
import 'package:flutter_application_1/services/jikan_service.dart';
import 'package:flutter_application_1/services/translator.dart';

class MangaInfoViewModel extends ChangeNotifier {
  final JikanService _service = JikanService();

  Manga manga;
  String translatedSynopsis = '';
  bool isLoading = false;
  bool hasError = false;
  bool isLiked = false;
  bool showLikeAnimation = false;

  MangaInfoViewModel({required this.manga});

  Future<void> loadMangaDetail() async {
    isLoading = true;
    hasError = false;

    translatedSynopsis = manga.synopsis;

    isLiked = LikeStorage.isMangaLiked(manga.id);

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
