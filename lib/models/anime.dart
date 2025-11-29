import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/identifiable.dart';

/// Représente un anime dans l'application.
///
/// Cette classe contient les informations principales nécessaires
/// pour lister un anime ou l'afficher dans une vue sommaire.
class Anime extends Identifiable {
  /// Identifiant unique de l'anime (provenant de l'API, ex: mal_id).
  @override
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

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'status': status,
      'score': score,
    };
  }
}
