import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga_detail.dart';

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

  /// URL de l'image de couverture du manga.
  final String imageUrl;

  /// Note moyenne du manga, si disponible.
  final double? score;

  final String status;

  /// Genre principal du manga (ex: Shonen, Seinen, Shojo).
  final String? genre;

  /// Constructeur de la classe Manga.
  ///
  /// Tous les champs sauf [score] et [genre] sont obligatoires.
  Manga({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.status,
    this.score,
    this.genre,
  });

  factory Manga.fromDetail(MangaDetail d) {
    return Manga(
      id: d.id,
      title: d.title,
      imageUrl: d.imageUrl,
      status: d.status,
      score: d.score,
    );
  }

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
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
