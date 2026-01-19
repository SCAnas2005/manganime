import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/models/year_seasons_enum.dart';

/// Interface abstraite définissant la structure de base pour tout service d’API
/// utilisé pour récupérer et convertir les données d’animes.
///
/// Cette classe doit être implémentée par tout service spécifique (ex: `JikanService`,
/// `AniListService`) afin d’assurer une interface commune à l’ensemble du code.
///
/// Chaque service API devra :
//// - Définir son `baseUrl`
/// - Implémenter les appels pour obtenir les animes les plus populaires (`getTopAnime`)
/// - Implémenter la récupération des détails d’un anime (`getFullDetailAnime`)
/// - Fournir les fonctions de conversion JSON → modèles (`jsonToAnime`, `jsonToAnimeDetail`)
///
/// Exemple d’utilisation :
/// ```dart
/// final api = JikanService();
/// final topAnimes = await api.getTopAnime();
/// final details = await api.getFullDetailAnime(topAnimes.first.id);
/// ```
abstract class ApiService {
  /// URL de base de l’API (exemple : `https://api.jikan.moe/v4`).
  String get baseUrl;

  /// Nombre maximal de requêtes autorisées par seconde pour respecter le Rate Limit de l'API.
  int get reqPerSec;

  /// Effectue une requête HTTP GET sur l'URI fournie et convertit la réponse en liste d'Animes.
  Future<List<Anime>> fetchAnimeList(Uri uri);

  /// Effectue une requête HTTP GET sur l'URI fournie et convertit la réponse en liste de Mangas.
  Future<List<Manga>> fetchMangaList(Uri uri);

  /// Effectue une recherche avancée d'Animes selon plusieurs critères de filtrage.
  ///
  /// [query] : Le texte de recherche.
  /// [genres] : Liste des genres à inclure.
  /// [sfw] : Si true, filtre les contenus adultes.
  Future<List<Anime>> searchAnime({
    int page = 1,
    required String query,
    int? limit,
    AnimeType? type, // le type d'anime (film, serie, ect)
    int? score,
    int? minScore,
    int? maxScore,
    MediaStatus? status,
    AnimeRating? rating,
    bool sfw = false,
    List<Genres>? genres,
    String? genresExclude,
    MediaOrderBy? orderBy,
    SortOrder? sort,
    String? letter,
    String? producers,
    String? startDate,
    String? endDate,
  });

  /// Effectue une recherche avancée de Mangas selon plusieurs critères de filtrage.
  ///
  /// [query] : Le texte de recherche.
  /// [type] : Format (Manga, Novel, Doujin, etc.).
  Future<List<Manga>> searchManga({
    int page = 1,
    required String query,
    int? limit,
    MangaType? type,
    int? score,
    int? minScore,
    int? maxScore,
    MediaStatus? status,
    bool sfw = false,
    List<Genres>? genres,
    String? genresExclude,
    MediaOrderBy? orderBy,
    SortOrder? sort,
    String? letter,
    String? magazines,
    String? startDate,
    String? endDate,
  });

  /// Récupère la liste des animes les plus populaires depuis l’API.
  ///
  /// Retourne une [Future] contenant une liste d’objets [Anime].
  /// En cas d’erreur réseau ou d’erreur JSON, une exception doit être levée.
  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? filter, // popular, trending, upcoming, etc.
    String? type, // tv, movie, ova, etc.
    MediaStatus? status, // airing, finished, etc.
    String? season, // winter, spring, summer, fall
    int? year,
    int? month,
    bool sfw = true,
  });

  /// Récupère le classement des meilleurs Mangas selon différents filtres de l'API.
  Future<List<Manga>> getTopManga({
    int page = 1,
    String? filter, // popular, favorite, etc.
    String? type, // manga, novel, one_shot, doujin, manhwa, manhua
    MediaStatus? status, // publishing, finished
    int? year,
    int? month,
    bool sfw = true,
  });

  /// Récupère les animes diffusés lors d'une saison spécifique (ex: Été 2024).
  ///
  /// [airingOnly] : Si true, ne récupère que les animes en cours de diffusion.
  Future<List<Anime>> getSeasonAnimes({
    int page = 1,
    int? year,
    Season? season,
    bool airingOnly = true,
    bool sfw = false,
  });

  /// Récupère toutes les informations détaillées concernant un anime spécifique.
  ///
  /// [id] correspond à l’identifiant unique de l’anime dans l’API.
  /// Retourne un objet [AnimeDetail] contenant les informations complètes.
  Future<Anime> getFullDetailAnime(int id);

  /// Récupère les informations complètes d'un manga via son identifiant unique.
  Future<Manga> getFullDetailManga(int id);

  /// Convertit une réponse JSON d’un anime basique (liste, recherche, top, etc.)
  /// en un objet [Anime].
  ///
  /// Doit être implémentée de manière spécifique à chaque API.
  Anime jsonToAnime(Map<String, dynamic> json);

  // Convertit une réponse JSON d’un anime basique (liste, recherche, top, etc.)
  /// en un objet [Manga].
  ///
  /// Doit être implémentée de manière spécifique à chaque API.
  Manga jsonToManga(Map<String, dynamic> json);
}
