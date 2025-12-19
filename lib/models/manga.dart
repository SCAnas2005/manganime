import 'package:flutter_application_1/models/identifiable.dart';

/// Représente un manga dans l'application.
///
/// Cette classe contient les informations principales nécessaires
/// pour lister un manga ou l'afficher dans une vue sommaire.
class Manga extends Identifiable {
  /// Identifiant unique de l'manga (provenant de l'API, ex: mal_id).
  @override
  final int id;

  /// Titre du manga.
  final String title;

  /// Synopsis du manga
  final String synopsis;

  /// URL de l'image de couverture du manga.
  final String imageUrl;

  /// Note moyenne du manga, si disponible.
  final double? score;

  final String status;

  final String type;

  /// Genre principal du manga (ex: Shonen, Seinen, Shojo).
  final List<String> genres;

  /// Constructeur de la classe Manga.
  ///
  /// Tous les champs sauf [score] et [genres] sont obligatoires.
  Manga({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.imageUrl,
    required this.status,
    required this.type,
    required this.score,
    required this.genres,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] as int,
      title: json['title'] as String,
      synopsis: (json["synopsis"] == null) ? "" : json["synopsis"] as String,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      type: json["type"] as String,
      genres: json["genres"] as List<String>,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'status': status,
      'score': score,
      'type': type,
      'genres': genres,
    };
  }
}
