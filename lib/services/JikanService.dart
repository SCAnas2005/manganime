import 'dart:convert';

import 'package:flutter_application_1/anime.dart';
import 'package:flutter_application_1/animeDetail.dart';
import 'package:flutter_application_1/services/ApiService.dart';
import 'package:http/http.dart' as http;

class JikanService extends ApiService {
  @override
  final String baseUrl = "https://api.jikan.moe/v4";

  @override
  Future<List<Anime>> getTopAnime({int page = 1}) async {
    final url = Uri.parse('$baseUrl/top/anime?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> animeList = jsonData['data'];

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

  @override
  Anime jsonToAnime(Map<String, dynamic> json) {
    return Anime(
      id: json["mal_id"],
      title: json['title_english']?.toString() ?? '',
      imageUrl: json['images']?['jpg']?['image_url']?.toString() ?? '',
      score: 0,
    );
  }

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
