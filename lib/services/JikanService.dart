import 'dart:convert';
import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/ApiService.dart';
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
}
