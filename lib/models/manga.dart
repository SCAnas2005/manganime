import 'package:flutter_application_1/models/author.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';

/// Représente un manga dans l'application.
///
/// Cette classe contient les informations principales nécessaires
/// pour lister un manga ou l'afficher dans une vue sommaire.
class Manga extends Identifiable {
  /// Identifiant unique de l'manga (provenant de l'API, ex: mal_id).
  @override
  final int id;

  /// Titre du manga.
  @override
  final String title;

  /// Synopsis du manga
  @override
  final String synopsis;

  /// URL de l'image de couverture du manga.
  @override
  final String imageUrl;

  /// Note moyenne du manga, si disponible.
  @override
  final double? score;

  /// Status du manga (en cours, fini, ect)
  @override
  final MediaStatus status;

  /// Type du manga
  final MangaType type;

  /// Genre principal du manga (ex: Shonen, Seinen, Shojo).
  @override
  final List<Genres> genres;

  /// Date de parution du manga
  @override
  DateTime? startDate;

  /// Date de fin de parution du manga
  @override
  DateTime? endDate;

  /// Liste des autheurs du manga
  final List<Author> authors;

  /// Nombre de chapitre, si le manga terminé
  final int? chapters;

  /// Nombre de volume du manga, si temriné
  final int? volumes;

  /// Démographique ciblé par le manga (Shonen, Seinen, Shojo, ect)
  final String? demographic;

  /// Magazine ou support de prépublication du manga
  final String? serialization;

  /// Constructeur de la classe Manga.
  Manga({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.imageUrl,
    required this.status,
    required this.type,
    required this.score,
    required this.genres,
    this.startDate,
    this.endDate,
    required this.authors,
    this.chapters,
    this.volumes,
    this.demographic,
    this.serialization,
  });

  /// Crée une instance de [Manga] à partir d'un objet JSON.
  ///
  /// Utilisé pour désérialiser les données provenant de la base de donnée.
  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] as int,
      title: json['title'] as String,
      synopsis: (json["synopsis"] == null) ? "" : json["synopsis"] as String,
      imageUrl: json['imageUrl'] as String,
      status: MediaStatusX.fromString(json['status']),
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      type: MangaTypeX.fromString(json["type"]),
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
      authors:
          (json["authors"] as List<dynamic>?)
              ?.map((a) => Author.fromJson(Map<String, dynamic>.from(a as Map)))
              .whereType<Author>()
              .toList() ??
          [],
      chapters: json["chapters"] as int?,
      volumes: json["volumes"] as int?,
      demographic: json["demographic"] as String?,
      serialization: json["serialization"] as String?,
    );
  }

  /// Crée une copie du manga avec certaines propriétés modifiées.
  ///
  /// Permet de travailler de manière immuable
  /// sans altérer l'instance originale.
  Manga copyWith({
    int? id,
    String? title,
    String? synopsis,
    String? imageUrl,
    MediaStatus? status,
    MangaType? type,
    List<Genres>? genres,
    double? score,
    DateTime? startDate,
    DateTime? endDate,
    List<Author>? authors,
    int? chapters,
    int? volumes,
    String? demographic,
    String? serialization,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      type: type ?? this.type,
      genres: genres ?? this.genres,
      score: score ?? this.score,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      authors: authors ?? this.authors,
      chapters: chapters ?? this.chapters,
      volumes: volumes ?? this.volumes,
      demographic: demographic ?? this.demographic,
      serialization: serialization ?? this.serialization,
    );
  }

  /// Convertit l'instance courante en un objet JSON.
  ///
  /// Utilisé pour la sérialisation (cache, favoris, persistance locale).
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
      'status': status.key,
      'score': score,
      'type': type.key,
      "genres": genres.map((g) => g.toReadableString()).toList(),
      "startDate": startDate?.toIso8601String(),
      "endDate": endDate?.toIso8601String(),
      "authors": authors.map((a) => a.toJson()).toList(),
      "chapters": chapters,
      "volumes": volumes,
      "demographic": demographic,
      "serialization": serialization,
    };
  }
}
