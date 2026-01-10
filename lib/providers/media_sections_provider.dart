// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/anime_sections.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/database_provider.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MediaSectionsProvider {
  static const String ANIME_SECTIONS_KEY = "anime_sections";
  static const String MANGA_SECTIONS_KEY = "manga_sections";
  static final MediaSectionsProvider instance = MediaSectionsProvider._();
  MediaSectionsProvider._();

  late Map<AnimeSections, Future<List<Anime>> Function({int page})>
  animeSectionTasks;
  late Map<MangaSections, Future<List<Manga>> Function({int page})>
  mangaSectionTasks;

  late Box _animeBox;
  late Box _mangaBox;

  Box getBoxByType<T extends Identifiable>() {
    if (T == Anime) return _animeBox;
    if (T == Manga) return _mangaBox;

    throw Exception(
      "[$MediaSectionsProvider] ${getBoxByType.toString()}: Unknow type $T",
    );
  }

  Future<void> init(ApiService api) async {
    _animeBox = await Hive.openBox(ANIME_SECTIONS_KEY);
    _mangaBox = await Hive.openBox(MANGA_SECTIONS_KEY);

    animeSectionTasks = {
      AnimeSections.popular: ({int page = 1}) async => await RequestQueue
          .instance
          .enqueue(() => api.getTopAnime(page: page, filter: "bypopularity")),
      AnimeSections.airing: ({int page = 1}) async => await RequestQueue
          .instance
          .enqueue(() => api.getSeasonAnimes(page: page)),
      AnimeSections.mostLiked: ({int page = 1}) async => await RequestQueue
          .instance
          .enqueue(() => api.getTopAnime(page: page, filter: "favorite")),
    };

    mangaSectionTasks = {
      MangaSections.popular: ({int page = 1}) async => await RequestQueue
          .instance
          .enqueue(() => api.getTopManga(page: page, filter: "bypopularity")),
      MangaSections.airing: ({int page = 1}) async =>
          await RequestQueue.instance.enqueue(
            () => api.getTopManga(page: page, status: MediaStatus.publishing),
          ),
      MangaSections.mostLiked: ({int page = 1}) async => await RequestQueue
          .instance
          .enqueue(() => api.getTopManga(page: page, filter: "favorite")),
    };
  }

  Future<void> fetchAllSectionsFromApi<T extends Identifiable>(
    ApiService api,
  ) async {
    if (T == Anime) {
      for (final entry in animeSectionTasks.entries) {
        await _processSection<Anime, AnimeSections>(
          entry.key,
          () => entry.value(page: 1),
          saveAnimeSection,
        );
      }
    } else if (T == Manga) {
      for (final entry in mangaSectionTasks.entries) {
        await _processSection<Manga, MangaSections>(
          entry.key,
          () => entry.value(page: 1),
          saveMangaSection,
        );
      }
    }
    // Démarrage des requetes.
  }

  Future<void> _processSection<T, S>(
    S sectionKey, // AnimeSections ou MangaSections
    Future<List<T>> Function() apiCall,
    Function(S, List<T>) saver,
  ) async {
    try {
      final items = await apiCall();
      if (items.isNotEmpty) {
        await saver(sectionKey, items);
      }
    } catch (e) {
      debugPrint(
        "[$MediaSectionsProvider] ${_processSection.toString()}: Error updating section $sectionKey: $e",
      );
    }
  }

  Future<void> reloadSections(ApiService service) async {
    await fetchAllSectionsFromApi<Anime>(service);
    await fetchAllSectionsFromApi<Manga>(service);
  }

  Future<void> clear<T extends Identifiable>() async {
    Box box = getBoxByType<T>();
    await box.clear();
  }

  Future<void> clearAnimes() async {
    await clear<Anime>();
  }

  Future<void> clearMangas() async {
    await clear<Manga>();
  }

  Future<void> clearAll() async {
    await clearAnimes();
    await clearMangas();
  }

  List<int> getAnimesId(AnimeSections section) {
    final ids = _animeBox.get(section.key, defaultValue: []);
    return List<int>.from(ids);
  }

  List<int> getMangasId(MangaSections section) {
    final ids = _mangaBox.get(section.key, defaultValue: []);
    return List<int>.from(ids);
  }

  Future<List<Anime>> getAnimes(AnimeSections section) async {
    final ids = getAnimesId(section);
    if (ids.isEmpty) return [];
    return await DatabaseProvider.instance.getMultipleAnimes(ids);
  }

  Future<List<Manga>> getMangas(MangaSections section) async {
    final ids = getMangasId(section);
    if (ids.isEmpty) return [];
    return await DatabaseProvider.instance.getMultipleMangas(ids);
  }

  Future<void> saveAnimeSection(
    AnimeSections section,
    List<Anime> animes,
  ) async {
    await DatabaseProvider.instance.saveMultipleAnimes(animes);
    MediaPathProvider.downloadBatchImages<Anime>(animes);
    final ids = animes.map((a) => a.id).toList();
    await _animeBox.put(section.key, ids);
  }

  Future<void> saveMangaSection(
    MangaSections section,
    List<Manga> mangas,
  ) async {
    await DatabaseProvider.instance.saveMultipleMangas(mangas);
    MediaPathProvider.downloadBatchImages<Manga>(mangas);
    final ids = mangas.map((a) => a.id).toList();
    await _mangaBox.put(section.key, ids);
  }
}
