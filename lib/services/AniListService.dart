import 'dart:convert';

import 'package:flutter_application_1/models/anime_detail.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/services/ApiService.dart';
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

  /// Récupère une liste paginée des animes les plus populaires.
  ///
  /// [page] : numéro de page (par défaut 1)
  /// [perPage] : nombre d’éléments par page (par défaut 20)
  @override
  Future<List<Anime>> getTopAnime({int page = 1, perPage = 20}) async {
    final query = r'''
    query($page: Int, $perPage: Int) {
      Page(page: $page, perPage: $perPage) {
        media(sort: POPULARITY_DESC, type: ANIME) {
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
    return data.map((json) {
      final title =
          json['title']['english'] ??
          json['title']['romaji'] ??
          json['title']['native'] ??
          '';
      return Anime(
        id: json['id'],
        title: title,
        imageUrl: json['coverImage']['large'] ?? '',
        score: 0,
      );
    }).toList();
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

    return Anime(id: json["id"], title: title, imageUrl: imageUrl, score: 0);
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
}
