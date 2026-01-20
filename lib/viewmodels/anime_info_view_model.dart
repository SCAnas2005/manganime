import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/like_storage_provider.dart';

/// ViewModel responsable de la logique métier de l'écran de détails d'un Anime.
///
/// Il gère l'état de chargement, les données détaillées de l'anime,
/// la traduction du synopsis et l'état des interactions utilisateur (Like).
class AnimeInfoViewModel extends ChangeNotifier {
  /// L'objet Anime actuellement affiché ou en cours de chargement.
  Anime? anime;

  /// Le synopsis de l'anime, potentiellement traduit ou formaté.
  String translatedSynopsis = '';

  /// Indique si une opération de chargement est en cours.
  bool isLoading = false;

  /// Indique si une erreur est survenue lors du chargement des données.
  bool hasError = false;

  /// État de favori (liké) de l'anime actuel.
  bool isLiked = false;

  /// Contrôle l'affichage de l'animation de superposition (overlay) lors d'un "Like".
  bool showLikeAnimation = false;

  /// Initialise le ViewModel avec un objet Anime de base.
  AnimeInfoViewModel({required this.anime});

  /// Charge les détails complets de l'anime et initialise l'état du "Like".
  ///
  /// [animeId] : L'identifiant unique de l'anime à charger.
  Future<void> loadAnimeDetail(int animeId) async {
    isLoading = true;
    hasError = false;

    translatedSynopsis =
        anime?.synopsis ??
        ""; //await Translator.translateToFrench(anime!.synopsis);

    isLiked = LikeStorage.getIdAnimeLiked().contains(anime?.id);
    isLoading = false;
    notifyListeners();
  }

  /// Alterne l'état du "Like" entre vrai et faux.
  ///
  /// [value] : Si fourni, force l'état à cette valeur. Sinon, inverse l'état actuel.
  void toggleLike({bool? value}) {
    isLiked = value ?? !isLiked;
    notifyListeners();
  }

  /// Déclenche l'animation visuelle du "Like" (souvent un gros cœur au milieu)
  /// suite à un double tap de l'utilisateur.
  ///
  /// [duration] : La durée pendant laquelle l'animation reste visible avant de disparaître.
  void likeAnimeOnDoubleTap({Duration duration = const Duration(seconds: 1)}) {
    showLikeAnimation = true;
    toggleLike();

    // Délai pour masquer automatiquement l'animation après l'affichage
    Future.delayed(duration, () {
      showLikeAnimation = false;
      notifyListeners();
    });
  }
}
