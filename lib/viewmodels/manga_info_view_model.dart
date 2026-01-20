import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';

/// ViewModel responsable de la gestion de l'état pour la page de détails d'un Manga.
///
/// Il fait le lien entre les données du [Manga] et l'interface utilisateur,
/// gérant notamment l'état du "Like" (Favori) et les animations associées.
class MangaInfoViewModel extends ChangeNotifier {
  /// L'objet Manga contenant les données à afficher (titre, image, auteurs, etc.).
  Manga manga;

  /// Le synopsis destiné à l'affichage (prêt pour une éventuelle traduction).
  String translatedSynopsis = '';

  /// Indique si les détails sont en cours de chargement.
  bool isLoading = false;

  /// Indique si une erreur est survenue lors de l'initialisation.
  bool hasError = false;

  /// État actuel du favori : true si le manga est liké par l'utilisateur.
  bool isLiked = false;

  /// Contrôle la visibilité de l'animation de cœur (overlay) lors d'un double-tap.
  bool showLikeAnimation = false;

  /// Constructeur injectant l'objet [Manga] initial.
  MangaInfoViewModel({required this.manga});

  /// Initialise la vue en chargeant les données et en vérifiant l'état du like.
  ///
  /// Récupère le synopsis et interroge le [LikeStorage] pour savoir si ce manga
  /// fait déjà partie des favoris enregistrés localement.
  Future<void> loadMangaDetail() async {
    isLoading = true;
    hasError = false;

    translatedSynopsis = manga.synopsis;

    // Vérification synchrone auprès du stockage local
    isLiked = LikeStorage.isMangaLiked(manga.id);

    isLoading = false;
    notifyListeners();
  }

  /// Bascule l'état "Liké" du manga.
  ///
  /// [value] : Si spécifié, force l'état à cette valeur. Sinon, inverse l'état actuel.
  /// Cette méthode ne fait que changer l'état visuel dans le ViewModel.
  /// La persistance réelle doit être gérée par la Vue via le Provider.
  void toggleLike({bool? value}) {
    isLiked = value ?? !isLiked;
    notifyListeners();
  }

  /// Gère l'interaction "Double Tap" (style Instagram).
  ///
  /// 1. Affiche l'animation du cœur.
  /// 2. Like le manga.
  /// 3. Masque l'animation après la [duration] définie.
  void likeMangaOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
    showLikeAnimation = true;
    toggleLike();

    Future.delayed(duration, () {
      showLikeAnimation = false;
      notifyListeners();
    });
  }
}
