import 'dart:convert';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/models/year_seasons_enum.dart';
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
  final int reqPerSec = 2;

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
  Future<List<Manga>> fetchMangaList(Uri uri) async {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> mangaList = jsonData['data'];

      // Conversion du JSON en liste d’objets Anime
      final List<Manga> mangas = mangaList
          .map<Manga>((manga) {
            return jsonToManga(manga);
          })
          .where((manga) => manga.title.isNotEmpty)
          .toList();

      return mangas;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  @override
  Future<List<Anime>> searchAnime({
    int page = 1,
    required String query,
    int? limit,
    AnimeType? type,
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
      if (genres != null) 'genres': genres.map((g) => g.id).join(','),
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

  @override
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
      'sfw': sfw.toString(),
      if (genres != null) 'genres': genres.map((g) => g.id).join(','),
      if (genresExclude != null) 'genres_exclude': genresExclude.toString(),
      if (orderBy != null) 'order_by': orderBy.toString(),
      if (sort != null) 'sort': sort.toString(),
      if (letter != null) 'letter': letter.toString(),
      if (magazines != null) 'magazines': magazines.toString(),
      if (startDate != null) 'start_date': startDate.toString(),
      if (endDate != null) 'end_date': endDate.toString(),
    };

    var url = Uri.parse(
      "$baseUrl/manga",
    ).replace(queryParameters: queryParameters);

    return fetchMangaList(url);
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
    MediaStatus? status, // airing, finished, etc.
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
      if (status != null) 'status': status.key,
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
    MediaStatus? status, // publishing, finished
    int? year,
    int? month,
    bool sfw = true,
  }) async {
    // Construction dynamique des paramètres de la query
    final queryParameters = <String, String>{
      'page': page.toString(),
      if (filter != null) 'filter': filter,
      if (type != null) 'type': type,
      if (status != null) 'status': status.key,
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

  @override
  Future<List<Anime>> getSeasonAnimes({
    int page = 1,
    int? year,
    Season? season,
    bool airingOnly = true,
    bool sfw = false,
  }) async {
    late Uri url;
    if (year != null && season != null) {
      url = Uri.parse("$baseUrl/seasons/$year/${season.key}");
    } else {
      url = Uri.parse("$baseUrl/seasons/now");
    }
    final queryParameters = <String, String>{
      "page": page.toString(),
      // if (airingOnly) "filter": "airing",
      "sfw": sfw.toString(),
    };
    url = url.replace(queryParameters: queryParameters);
    return await fetchAnimeList(url);
  }

  // =======
  //   Future<List<Anime>> searchAnime({
  //     String query =""
  //     }) async {

  //       final queryParameters = <String, String>{
  //         'q': query,
  //          };

  //        final url = Uri.parse(
  //         '$baseUrl/anime',
  //       ).replace(queryParameters: queryParameters);

  //       final response = await http.get(url);

  //       if (response.statusCode == 200) {
  //         final jsonData = json.decode(response.body);
  //         final List<dynamic> animeList = jsonData['data'];

  //         // Conversion du JSON en liste d’objets Anime
  //         final List<Anime> animes = animeList
  //             .map<Anime>((anime) {
  //               return jsonToAnime(anime);
  //             })
  //             .where((anime) => anime.title.isNotEmpty)
  //             .toList();

  //         return animes;
  //       } else {
  //         throw Exception('Erreur ${response.statusCode}');
  //       }
  //     }

  // >>>>>>> d736284cb48dda01c35ea0580f4e23f912b35d19

  /// Récupère les informations détaillées d’un anime via son [id MAL].
  ///
  /// Retourne un objet [AnimeDetail].
  @override
  Future<Anime> getFullDetailAnime(int id) async {
    final url = Uri.parse('$baseUrl/anime/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dynamic animeJson = jsonData["data"];
      final Anime anime = jsonToAnime(animeJson);
      return anime;
    } else {
      throw Exception('Erreur ${response.statusCode}');
    }
  }

  /// Récupère les informations détaillées d’un manga via son [id MAL].
  ///
  /// Retourne un objet [MangaDetail].
  @override
  Future<Manga> getFullDetailManga(int id) async {
    final url = Uri.parse('$baseUrl/manga/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dynamic mangaJson = jsonData["data"];

      final Manga manga = jsonToManga(mangaJson);
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
      synopsis: json['synopsis'] ?? '',
      imageUrl: json['images']?['jpg']?['image_url']?.toString() ?? '',
      status: MediaStatusX.fromJikan(json["status"]),
      score: (json["score"] ?? 0).toDouble(),
      genres: (json["genres"] != null)
          ? (json["genres"] as List)
                .map((genreJson) => GenreX.fromString(genreJson["name"]))
                .where((g) => g != null)
                .map((g) => g!)
                .toList()
          : [],
    );
  }

  /// Convertit un objet JSON (manga basique) en instance de [Manga].
  @override
  Manga jsonToManga(Map<String, dynamic> json) {
    return Manga(
      id: json["mal_id"],
      title:
          json['title_english']?.toString() ?? json['title']?.toString() ?? '',
      synopsis: json["synopsis"] ?? '',
      imageUrl: json['images']?['jpg']?['image_url']?.toString() ?? '',
      status: MediaStatusX.fromJikan(json["status"]),
      score: (json["score"] ?? 0).toDouble(),
      type: json["type"],
      genres: (json["genres"] != null)
          ? (json["genres"] as List)
                .map((genreJson) => GenreX.fromString(genreJson["name"]))
                .where((g) => g != null)
                .map((g) => g!)
                .toList()
          : [],
    );
  }

  // Future<List<Anime>> searchAnime({String query = ""}) async {
  //   final queryParameters = <String, String>{'q': query};

  //   final url = Uri.parse(
  //     '$baseUrl/anime',
  //   ).replace(queryParameters: queryParameters);

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //     final List<dynamic> animeList = jsonData['data'];

  //     // Conversion du JSON en liste d’objets Anime
  //     final List<Anime> animes = animeList
  //         .map<Anime>((anime) {
  //           return jsonToAnime(anime);
  //         })
  //         .where((anime) => anime.title.isNotEmpty)
  //         .toList();

  //     return animes;
  //   } else {
  //     throw Exception('Erreur ${response.statusCode}');
  //   }
  // }
}
