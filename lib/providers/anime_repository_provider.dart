import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/providers/anime_cache_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';

class AnimeRepository {
  final ApiService api;

  AnimeRepository({required this.api});

  Future<Anime> getAnime(int id) async {
    // 1. Cache
    var data = await AnimeCache.instance.get(id);
    if (data != null) {
      return data;
    }

    // 2. API
    final animeDetail = await api.getFullDetailAnime(id);
    final anime = Anime.fromDetail(animeDetail);

    // 3. Sauvegarde
    await AnimeCache.instance.save(anime);
    return anime;
  }
}
