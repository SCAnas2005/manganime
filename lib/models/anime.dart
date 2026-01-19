import 'package:flutter_application_1/models/identifiable_enums.dart';
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
  @override
  final String title;

  /// Synopsis de l'anime
  @override
  final String synopsis;

  /// URL de l'image de couverture de l'anime.
  @override
  final String imageUrl;

  /// Note moyenne de l'anime, si disponible.
  @override
  final double? score;

  /// Le status de l'anime
  @override
  final MediaStatus status;

  /// Genre de l'anime (action, aventure, ect)
  @override
  final List<Genres> genres;

  /// Date de sortie de l'anime
  @override
  DateTime? startDate;

  /// Date de fin s'il y en a une
  @override
  DateTime? endDate;

  /// Studio qui a crée l'anime
  final String studio;

  /// Le type d'anime (série, film, ova, ect)
  final AnimeType type;

  /// L'anime rating
  final AnimeRating rating;

  /// Le nombre d'épisode s'il est fini
  final int? episodes;

  /// Constructeur de la classe Anime.
  Anime({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.imageUrl,
    required this.status,
    required this.genres,
    this.score,
    this.startDate,
    this.endDate,
    required this.studio,
    required this.type,
    required this.rating,
    this.episodes,
  });

  /// Crée une instance de [Anime] à partir d'un objet JSON.
  ///
  /// Utilisé principalement pour la désérialisation
  /// des données provenant de l'API
  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] as int,
      title: json['title'] as String,
      synopsis: (json['synopsis'] == null) ? "" : json["synopsis"] as String,
      imageUrl: json['imageUrl'] as String,
      status: MediaStatusX.fromString(json['status']),
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      genres:
          (json["genres"] as List<dynamic>?)
              ?.map((g) => GenreX.fromString(g.toString()))
              .whereType<Genres>() // <-- filtre les null
              .toList() ??
          [],
      startDate: json["startDate"] == null
          ? null
          : DateTime.tryParse(json["startDate"]),
      endDate: json["endDate"] == null
          ? null
          : DateTime.tryParse(json["endDate"]),
      studio: json["studio"] as String? ?? "Inconnu",
      type: AnimeTypeX.fromString(json["type"] as String?),
      rating: AnimeRatingX.fromString(json["rating"] as String?),
      episodes: json["episodes"] as int?,
    );
  }

  /// Convertit l'instance courante en un objet JSON.
  ///
  /// Utilisé pour la sérialisation (cache local, favoris, etc.).
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'status': status.key,
      'score': score,
      "genres": genres.map((g) => g.toReadableString()).toList(),
      "startDate": startDate?.toIso8601String(),
      "endDate": endDate?.toIso8601String(),
      "studio": studio,
      "type": type.key,
      "rating": rating.key,
      "episodes": episodes,
    };
  }

  /// Crée une copie de l'anime avec certaines propriétés modifiées.
  ///
  /// Pratique pour les mises à jour immuables
  /// sans modifier l'instance originale.
  Anime copyWith({
    int? id,
    String? title,
    String? synopsis,
    String? imageUrl,
    MediaStatus? status,
    List<Genres>? genres,
    double? score,
    DateTime? startDate,
    DateTime? endDate,
    String? studio,
    AnimeType? type,
    AnimeRating? rating,
    int? episodes,
  }) {
    return Anime(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      score: score ?? this.score,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      studio: studio ?? this.studio,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      episodes: episodes ?? this.episodes,
    );
  }

  /// Compare deux animes sur la base de leur identifiant unique.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Anime && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
