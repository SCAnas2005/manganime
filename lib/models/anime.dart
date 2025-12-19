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

  /// Synopsis de l'anime
  final String synopsis;

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
    required this.synopsis,
    required this.imageUrl,
    required this.status,
    required this.genres,
    this.score,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] as int,
      title: json['title'] as String,
      synopsis: (json['synopsis'] == null) ? "" : json["synopsis"] as String,
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'status': status,
      'score': score,
      "genres": genres.map((g) => g.toReadableString()).toList(),
    };
  }

  Anime copyWith({
    int? id,
    String? title,
    String? synopsis,
    String? imageUrl,
    String? status,
    List<AnimeGenre>? genres,
    double? score,
  }) {
    return Anime(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Anime && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
