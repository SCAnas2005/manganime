import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/manga_cache_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';

class MangaRepository {
  final ApiService api;

  MangaRepository({required this.api});

  Future<Manga> getManga(int id) async {
    // 1. Cache
    var data = await MangaCache.instance.get(id);
    if (data != null) {
      return data;
    }

    // 2. API
    final manga = await api.getFullDetailManga(id);

    // 3. Sauvegarde
    await MangaCache.instance.save(manga);
    return manga;
  }
}
