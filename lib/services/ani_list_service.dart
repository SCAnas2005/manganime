import 'dart:convert';

import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/models/manga_detail.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Service d’accès à l’API **AniList** via GraphQL.
///
/// Permet de récupérer la liste des animes populaires
/// et les informations détaillées d’un anime spécifique.
/// Implémente l’interface [ApiService].
class AniListService implements ApiService {
  /// URL de base pour les requêtes GraphQL AniList.
  @override
  String get baseUrl => "https://graphql.anilist.co";

  /// Récupère une liste paginée des animes depuis AniList.
  ///
  /// Permet de filtrer et trier les résultats selon différents critères.
  ///
  /// [page] : numéro de page à charger (par défaut `1`).
  /// [filter] : type de tri (`popular`, `trending`, `upcoming`, etc.).
  /// [type] : type d’anime (`TV`, `MOVIE`, `OVA`, etc.).
  /// [status] : statut de diffusion (`RELEASING`, `FINISHED`, etc.).
  /// [season] : saison (`WINTER`, `SPRING`, `SUMMER`, `FALL`).
  /// [year] : année de diffusion.
  /// [month] : mois de diffusion (non utilisé par AniList, présent pour compatibilité avec ApiService).
  /// [sfw] : `true` pour exclure le contenu adulte, `false` pour inclure.
  /// [perPage] : nombre d’éléments par page (par défaut `20`, utilisé uniquement par AniList).
  ///
  /// Retourne une liste d’objets [Anime].
  @override
  Future<List<Anime>> getTopAnime({
    int page = 1,
    String? filter,
    String? type,
    String? status,
    String? season,
    int? year,
    int? month, // Obligatoire pour correspondre à la classe mère
    bool sfw = true,
    int perPage = 20,
  }) async {
    // Construction du tri
    final filters = <String>[];
    if (filter != null) {
      switch (filter.toLowerCase()) {
        case 'popular':
          filters.add('POPULARITY_DESC');
          break;
        case 'trending':
          filters.add('TRENDING_DESC');
          break;
        case 'upcoming':
          filters.add('UPCOMING_DESC');
          break;
        default:
          filters.add('POPULARITY_DESC');
      }
    } else {
      filters.add('POPULARITY_DESC');
    }

    final mediaFilters = <String>[];
    if (type != null) mediaFilters.add('type: $type');
    if (status != null) mediaFilters.add('status: $status');
    if (season != null) mediaFilters.add('season: $season');
    if (year != null) mediaFilters.add('seasonYear: $year');
    // AniList n'a pas de month, on ignore ce paramètre
    if (!sfw) mediaFilters.add('isAdult: false');

    final mediaFilterString = mediaFilters.isNotEmpty
        ? mediaFilters.join(', ')
        : '';

    final query =
        '''
    query(\$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(sort: [${filters.join(', ')}]${mediaFilterString.isNotEmpty ? ', $mediaFilterString' : ''}) {
          id
          title { romaji english native }
          coverImage { large }
        }
      }
    }
  ''';

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'variables': {'page': page, 'perPage': perPage},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur AniList: ${response.statusCode}');
    }

    final data = jsonDecode(response.body)['data']['Page']['media'] as List;
    return data.map((json) => jsonToAnime(json)).toList();
  }

  /// Récupère les informations détaillées d’un anime à partir de son [id].
  @override
  Future<AnimeDetail> getFullDetailAnime(int id) async {
    const query = r'''
      query($id: Int) {
        Media(id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            extraLarge
          }
          description(asHtml: false)
          averageScore
          type
          status
          genres
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'variables': {'id': id},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur API AniList: ${response.statusCode}");
    }

    final json = jsonDecode(response.body)['data']['Media'];
    return jsonToAnimeDetail(json);
  }

  /// Convertit un JSON d’anime simple en objet [Anime].
  @override
  Anime jsonToAnime(Map<String, dynamic> json) {
    final title =
        json['title']['english'] ??
        json['title']['romaji'] ??
        json['title']['native'] ??
        '';

    final imageUrl = json['coverImage']['large'] ?? '';

    return Anime(
      id: json["id"],
      title: title,
      imageUrl: imageUrl,
      score: 0,
      status: json["status"] ?? "",
    );
  }

  /// Convertit un JSON détaillé d’un anime en objet [AnimeDetail].
  @override
  AnimeDetail jsonToAnimeDetail(Map<String, dynamic> json) {
    return AnimeDetail(
      id: json['id'],
      title:
          json['title']['english'] ??
          json['title']['romaji'] ??
          json['title']['native'] ??
          '',
      synopsis: json['description'] ?? '',
      imageUrl: json['coverImage']['extraLarge'] ?? '',
      score: (json['averageScore'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
    );
  }

  @override
  Manga jsonToManga(Map<String, dynamic> json) {
    // TODO: implement jsonToManga
    throw UnimplementedError();
  }

  @override
  MangaDetail jsonToMangaDetail(Map<String, dynamic> json) {
    // TODO: implement jsonToMangaDetail
    throw UnimplementedError();
  }

  @override
  Future<MangaDetail> getFullDetailManga(int id) {
    // TODO: implement getFullDetailManga
    throw UnimplementedError();
  }

  @override
  Future<List<Manga>> getTopManga({
    int page = 1,
    String? filter,
    String? type,
    String? status,
    int? year,
    int? month,
    bool sfw = true,
  }) {
    // TODO: implement getTopManga
    throw UnimplementedError();
  }
}
