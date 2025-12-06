import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/anime_enums.dart';
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

  /// Le status de l'anime
  final String status;

  /// Genre de l'anime (action, aventure, ect)
  final List<AnimeGenre> genres;

  /// Constructeur de la classe Anime.
  ///
  /// Tous les champs sauf [score] sont obligatoires.
  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.genres,
    this.score,
  });

  factory Anime.fromDetail(AnimeDetail d) {
    return Anime(
      id: d.id,
      title: d.title,
      imageUrl: d.imageUrl,
      status: d.status,
      score: d.score,
      genres: d.genres,
    );
  }

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      genres:
          (json["genres"] as List<dynamic>?)
              ?.map((g) => AnimeGenreX.fromString(g.toString()))
              .whereType<AnimeGenre>() // <-- filtre les null
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'status': status,
      'score': score,
      "genres": genres.map((g) => g.toReadableString()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Anime && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
