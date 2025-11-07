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

  /// Constructeur de la classe Anime.
  ///
  /// Tous les champs sauf [score] sont obligatoires.
  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.score,
  });
}
