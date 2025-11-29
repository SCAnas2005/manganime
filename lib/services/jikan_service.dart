import 'dart:convert';
import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/models/manga_detail.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Service d’accès à l’API **Jikan (MyAnimeList)**.
///
/// Fournit des méthodes pour :
/// — Récupérer la liste des animes populaires.
/// — Obtenir les détails complets d’un anime.
///
/// Cette classe implémente [ApiService].
class JikanService extends ApiService {
  /// URL de base de l’API Jikan.
  @override
  final String baseUrl = "https://api.jikan.moe/v4";

  @override
  Future<List<Anime>> fetchAnimeList(Uri uri) async {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> animeList = jsonData['data'];

      // Conversion du JSON en liste d’objets Anime
      final List<Anime> animes = animeList
          .map<Anime>((anime) {
            return jsonToAnime(anime);
          })
          .where((anime) => anime.title.isNotEmpty)
          .toList();

      return animes;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  @override
  Future<List<Anime>> search({
    int page = 1,
    required String query,
    int? limit,
    AnimeType? type,
    int? score,
    int? minScore,
    int? maxScore,
    AnimeStatus? status,
    AnimeRating? rating,
    bool sfw = false,
    String? genres,
    String? genresExclude,
    AnimeOrderBy? orderBy,
    AnimeSortBy? sort,
    String? letter,
    String? producers,
    String? startDate,
    String? endDate,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'q': query,
      if (limit != null) 'limit': limit.toString(),
      if (type != null) 'type': type.toString(),
      if (score != null) 'score': score.toString(),
      if (minScore != null) 'min_score': minScore.toString(),
      if (maxScore != null) 'max_score': maxScore.toString(),
      if (status != null) 'status': status.toString(),
      if (rating != null) 'rating': rating.toString(),
      'sfw': sfw.toString(),
      if (genres != null) 'genres': genres.toString(),
      if (genresExclude != null) 'genres_exclude': genresExclude.toString(),
      if (orderBy != null) 'order_by': orderBy.toString(),
      if (sort != null) 'sort': sort.toString(),
      if (letter != null) 'letter': letter.toString(),
      if (producers != null) 'producers': producers.toString(),
      if (startDate != null) 'start_date': startDate.toString(),
      if (endDate != null) 'end_date': endDate.toString(),
    };
    var url = Uri.parse(
      "$baseUrl/anime",
    ).replace(queryParameters: queryParameters);
    return fetchAnimeList(url);
  }

  /// Récupère une liste d’animes les plus populaires depuis Jikan.
  ///
  /// [page] : numéro de page à charger (par défaut `1`).
  ///
  /// Retourne une liste d’objets [Anime].
  @override
  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? filter, // popular, trending, upcoming, etc.
    String? type, // tv, movie, ova, etc.
    String? status, // airing, finished, etc.
    String? season, // winter, spring, summer, fall
    int? year,
    int? month,
    bool sfw = true,
  }) async {
    // Construction dynamique des paramètres de la query
    final queryParameters = <String, String>{
      'page': page.toString(),
      if (filter != null) 'filter': filter,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (season != null) 'season': season,
      if (year != null) 'year': year.toString(),
      if (month != null) 'month': month.toString(),
      'sfw': sfw.toString(),
    };

    final url = Uri.parse(
      '$baseUrl/top/anime',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> animeList = jsonData['data'];

      // Conversion du JSON en liste d’objets Anime
      final List<Anime> animes = animeList
          .map<Anime>((anime) {
            return jsonToAnime(anime);
          })
          .where((anime) => anime.title.isNotEmpty)
          .toList();

      return animes;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  /// Récupère une liste de mangas les plus populaires depuis Jikan.
  ///
  /// [page] : numéro de page à charger (par défaut `1`).
  ///
  /// Retourne une liste d’objets [Manga].
  @override
  Future<List<Manga>> getTopManga({
    int page = 1,
    String? filter, // popular, favorite, etc.
    String? type, // manga, novel, one_shot, doujin, manhwa, manhua
    String? status, // publishing, finished
    int? year,
    int? month,
    bool sfw = true,
  }) async {
    // Construction dynamique des paramètres de la query
    final queryParameters = <String, String>{
      'page': page.toString(),
      if (filter != null) 'filter': filter,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (year != null) 'year': year.toString(),
      if (month != null) 'month': month.toString(),
      'sfw': sfw.toString(),
    };

    final url = Uri.parse(
      '$baseUrl/top/manga',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> mangaList = jsonData['data'];

      // Conversion JSON → Liste<Manga>
      final List<Manga> mangas = mangaList
          .map<Manga>((m) => jsonToManga(m))
          .where((m) => m.title.isNotEmpty)
          .toList();

      return mangas;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  /// Récupère les informations détaillées d’un anime via son [id MAL].
  ///
  /// Retourne un objet [AnimeDetail].
  @override
  Future<AnimeDetail> getFullDetailAnime(int id) async {
    final url = Uri.parse('$baseUrl/anime/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dynamic animeJson = jsonData["data"];
      final AnimeDetail anime = jsonToAnimeDetail(animeJson);
      return anime;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  /// Récupère les informations détaillées d’un manga via son [id MAL].
  ///
  /// Retourne un objet [MangaDetail].
  @override
  Future<MangaDetail> getFullDetailManga(int id) async {
    final url = Uri.parse('$baseUrl/manga/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dynamic mangaJson = jsonData["data"];

      final MangaDetail manga = jsonToMangaDetail(mangaJson);
      return manga;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  /// Convertit un objet JSON (anime basique) en instance de [Anime].
  @override
  Anime jsonToAnime(Map<String, dynamic> json) {
    return Anime(
      id: json["mal_id"],
      title: json['title_english']?.toString() ?? '',
      imageUrl: json['images']?['jpg']?['image_url']?.toString() ?? '',
      status: json["status"] ?? "",
      score: (json["score"] ?? 0).toDouble(),
    );
  }

  /// Convertit un objet JSON détaillé en instance de [AnimeDetail].
  @override
  AnimeDetail jsonToAnimeDetail(Map<String, dynamic> json) {
    return AnimeDetail(
      id: json['mal_id'],
      title: json['title'] ?? '',
      synopsis: json['synopsis'] ?? '',
      imageUrl: json['images']?['jpg']?['large_image_url'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      genres: (json['genres'] as List<dynamic>)
          .map((g) => g['name'].toString())
          .toList(),
    );
  }

  /// Convertit un objet JSON (manga basique) en instance de [Manga].
  @override
  Manga jsonToManga(Map<String, dynamic> json) {
    // Extraire le premier genre si disponible
    String? genre;
    if (json['genres'] != null && (json['genres'] as List).isNotEmpty) {
      genre = json['genres'][0]['name']?.toString();
    }
    
    return Manga(
      id: json["mal_id"],
      title:
          json['title_english']?.toString() ?? json['title']?.toString() ?? '',
      imageUrl: json['images']?['jpg']?['image_url']?.toString() ?? '',
      status: json["status"] ?? "",
      score: (json["score"] ?? 0).toDouble(),
      genre: genre,
    );
  }

  /// Convertit un objet JSON détaillé en instance de [MangaDetail].
  @override
  MangaDetail jsonToMangaDetail(Map<String, dynamic> json) {
    return MangaDetail(
      id: json['mal_id'],
      title: json['title'] ?? '',
      synopsis: json['synopsis'] ?? '',
      imageUrl: json['images']?['jpg']?['large_image_url'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      genres: (json['genres'] as List<dynamic>)
          .map((g) => g['name'].toString())
          .toList(),
    );
  }
}
