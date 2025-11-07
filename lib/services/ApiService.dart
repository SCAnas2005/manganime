import 'package:flutter_application_1/anime.dart';
import 'package:flutter_application_1/animeDetail.dart';

abstract class ApiService {
  String get baseUrl;
  Future<List<Anime>> getTopAnime();
  Future<AnimeDetail> getFullDetailAnime(int id);

  Anime jsonToAnime(Map<String, dynamic> json);
  AnimeDetail jsonToAnimeDetail(Map<String, dynamic> json);
}
