/// Représente un manga dans l'application.
///
/// Cette classe contient les informations principales nécessaires
/// pour lister un manga ou l'afficher dans une vue sommaire.
class Manga {
  /// Identifiant unique de l'manga (provenant de l'API, ex: mal_id).
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
}
