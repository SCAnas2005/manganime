/// Représente les informations détaillées d’un anime.
///
/// Cet objet contient toutes les données retournées par l’API Jikan
/// lorsqu’on interroge le détail complet d’un anime (titre, synopsis, genres, etc.).
class MangaDetail {
  /// Identifiant unique de l’anime (correspond à `mal_id` sur MyAnimeList).
  final int id;

  /// Titre complet de l’anime.
  final String title;

  /// Résumé ou synopsis de l’anime (souvent en anglais).
  final String synopsis;

  /// URL de l’image (généralement l’affiche principale).
  final String imageUrl;

  /// Note moyenne attribuée à l’anime.
  final double score;

  /// Type d’anime (TV, Movie, OVA, etc.).
  final String type;

  /// Statut de diffusion (ex : "Finished Airing", "Currently Airing").
  final String status;

  /// Liste des genres associés à l’anime (Action, Drama, etc.).
  final List<String> genres;

  /// Constructeur principal.
  MangaDetail({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.imageUrl,
    required this.score,
    required this.type,
    required this.status,
    required this.genres,
  });
}
