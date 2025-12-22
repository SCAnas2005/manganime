import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnimeSectionsProvider {
  // ignore: constant_identifier_names
  static const String ANIME_SECTIONS_KEY = "animes_sections";
  static final AnimeSectionsProvider instance = AnimeSectionsProvider._();
  AnimeSectionsProvider._();

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(ANIME_SECTIONS_KEY);
  }

  Future<void> fetchAllSectionsFromApi(ApiService api) async {
    final Map<AnimeSections, Future<List<Anime>> Function()> sectionTasks = {
      AnimeSections.popular: () async => await RequestQueue.instance.enqueue(
        () => api.getTopAnime(page: 1, filter: "bypopularity"),
      ),
      AnimeSections.airing: () async => await RequestQueue.instance.enqueue(
        () => api.getSeasonAnimes(page: 1),
      ),
      AnimeSections.mostLiked: () async => await RequestQueue.instance.enqueue(
        () => api.getTopAnime(page: 1, filter: "favorite"),
      ),
    };

    // Démarrage des requetes.
    for (final entry in sectionTasks.entries) {
      final section = entry.key;
      final apiCall = entry.value;
      try {
        final animes = await apiCall();
        if (animes.isNotEmpty) {
          await saveSection(section, animes);
        }
      } catch (e) {
        debugPrint("[AnimeSectionsProvider] fetchAllSectionsFromApi: $e");
      }
    }
  }

  List<int> getAnimesId(AnimeSections section) {
    final ids = _box.get(section.key, defaultValue: []);
    return List<int>.from(ids);
  }

  Future<List<Anime>> getAnimes(AnimeSections section) async {
    final ids = getAnimesId(section);
    if (ids.isEmpty) return [];
    return await DatabaseProvider.instance.getMultipleAnimes(ids);
  }

  Future<void> saveSection(AnimeSections section, List<Anime> animes) async {
    await DatabaseProvider.instance.saveMultipleAnimes(animes);
    await MediaPathProvider.downloadBatchImages<Anime>(animes);
    final ids = animes.map((a) => a.id).toList();
    await _box.put(section.key, ids);
  }
}
