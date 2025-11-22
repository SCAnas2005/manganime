import 'package:flutter_application_1/models/anime_detail.dart';

/// Représente un anime dans l'application.
///
/// Cette classe contient les informations principales nécessaires
/// pour lister un anime ou l'afficher dans une vue sommaire.
class Anime {
  /// Identifiant unique de l'anime (provenant de l'API, ex: mal_id).
  final int id;

  /// Titre de l'anime.
  final String title;

  /// URL de l'image de couverture de l'anime.
  final String imageUrl;

  /// Note moyenne de l'anime, si disponible.
  final double? score;

  final String status;

  /// Constructeur de la classe Anime.
  ///
  /// Tous les champs sauf [score] sont obligatoires.
  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    this.score,
  });

  factory Anime.fromDetail(AnimeDetail d) {
    return Anime(
      id: d.id,
      title: d.title,
      imageUrl: d.imageUrl,
      status: d.status,
      score: d.score,
    );
  }
}
