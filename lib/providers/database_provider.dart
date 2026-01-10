// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/media_path_provider.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/image_sync_service.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseProvider {
  static const String ANIMES_KEY = "animes_key";
  static const String MANGAS_KEY = "mangas_key";

  static late final Box _animeBox;
  static late final Box _mangaBox;

  static const int ITEM_PER_PAGE = 25;

  static DatabaseProvider instance = DatabaseProvider();
  int get animeLength => length<Anime>();
  int get mangaLength => length<Manga>();

  int length<T extends Identifiable>() {
    return getBoxByType<T>().length;
  }

  Future<void> clear<T extends Identifiable>() async {
    await getBoxByType<T>().clear();
  }

  static Future<void> init() async {
    _animeBox = await Hive.openBox(ANIMES_KEY);
    _mangaBox = await Hive.openBox(MANGAS_KEY);
    debugPrint("[Database] initialized");
  }

  Future<void> populate<T extends Identifiable>(
    ApiService service,
    int total,
  ) async {
    Future<List<T>> fetchPage(int p) async {
      try {
        if (T == Anime) {
          return await RequestQueue.instance.enqueue(
                () => service.getTopAnime(page: p),
              )
              as List<T>;
        } else if (T == Manga) {
          return await RequestQueue.instance.enqueue(
                () => service.getTopManga(page: p),
              )
              as List<T>;
        }
        throw UnsupportedError('Type $T non supporté');
      } catch (e) {
        await Future.delayed(const Duration(seconds: 1));
      }
      return [];
    }

    // --- PAGE 1 ---
    final listPage1 = await fetchPage(1);
    await instance._saveMultiple<T>(listPage1);

    // Ajout Page 1 à la queue
    for (var item in listPage1) {
      // debugPrint("from api importing anime : id : ${item.id}");
      await ImageSyncService.instance.addToQueue(item);
    }

    ImageSyncService.instance.processQueue();

    // --- PAGES SUIVANTES ---
    final int totalPages = (total / 25).ceil();

    Future.microtask(() async {
      debugPrint(
        "[DatabaseProvider] populate<$T> : Démarrage background ($totalPages pages)...",
      );

      for (int page = 2; page <= totalPages; page++) {
        // Check internet pour éviter de spammer si coupé
        if (!await NetworkService.isConnected) {
          debugPrint("Populate en pause (pas d'internet)");
          break;
        }

        try {
          final list = await fetchPage(
            page,
          ); // 'list' contient les nouveaux items

          await _saveMultiple<T>(list);

          await Future.wait(
            list.map((item) {
              // debugPrint("from api importing anime : id : ${item.id}");
              return ImageSyncService.instance.addToQueue(item);
            }),
          );

          ImageSyncService.instance.processQueue();

          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint("[DatabaseProvider] Erreur page $page: $e");
        }
      }

      debugPrint("[DatabaseProvider] populate<$T> : Terminé.");

      // Dernier passage de balai
      ImageSyncService.instance.processQueue();
    });
  }

  /// Télécharge les images d'une liste en parallèle.
  /// Ne modifie pas les objets, crée juste les fichiers sur le disque.
  Future<void> downloadImagesOnly<T extends Identifiable>(List<T> list) async {
    // On lance tous les téléchargements de la liste en même temps
    await MediaPathProvider.downloadBatchImages<T>(list);
  }

  Future<void> downloadImageOnly<T extends Identifiable>(T identifiable) async {
    await MediaPathProvider.downloadFileImage<T>(identifiable);
  }

  Future<void> saveFromFunction<T extends Identifiable>(
    FutureOr<List<T>> Function() function,
    Map map,
  ) async {
    List<T> results = await function();
    await _saveMultiple(results);
  }

  Box getBoxByType<T extends Identifiable>() {
    if (T == Anime) return _animeBox;
    if (T == Manga) return _mangaBox;
    throw UnsupportedError('Type $T not supported');
  }

  Map<String, dynamic> _castToMap(dynamic data) {
    // .from() crée une nouvelle Map propre avec les bons types
    return Map<String, dynamic>.from(data as Map);
  }

  T _fromJson<T extends Identifiable>(dynamic raw) {
    final Map<String, dynamic> data = _castToMap(raw);

    if (T == Anime) return Anime.fromJson(data) as T;
    if (T == Manga) return Manga.fromJson(data) as T;
    throw UnsupportedError('Type $T not supported');
  }

  List<T> _getAll<T extends Identifiable>() {
    Box box = getBoxByType<T>();
    return box.values.map((raw) {
      final Map<String, dynamic> typedMap = Map<String, dynamic>.from(raw);

      return _fromJson<T>(typedMap);
    }).toList();
  }

  Future<T?> _get<T extends Identifiable>(int id) async {
    Box box = getBoxByType<T>();
    final dynamic raw = box.get(id);
    if (raw == null) return null;
    final Map<String, dynamic> typedMap = Map<String, dynamic>.from(raw);

    return _fromJson<T>(typedMap);
  }

  Future<List<T>> _getMultiples<T extends Identifiable>(List<int> ids) async {
    Box box = getBoxByType<T>();
    List<T> results = [];
    for (var id in ids) {
      final raw = await box.get(id);
      if (raw != null) {
        results.add(_fromJson<T>(raw));
      }
    }

    return results;
  }

  Future<void> _save<T extends Identifiable>(T identifiable) async {
    Box box = getBoxByType<T>();
    try {
      await box.put(identifiable.id, identifiable.toJson());
    } catch (e) {
      debugPrint("Error _save<T> : box.put failed $e");
    }
  }

  Future<void> _saveMultiple<T extends Identifiable>(
    List<T> identifiables,
  ) async {
    Box box = getBoxByType<T>();
    try {
      final Map<int, Map<String, dynamic>> entries = {
        for (var item in identifiables) item.id: item.toJson(),
      };
      debugPrint("Saving entries : ${identifiables.map((i) => i.id)}");
      await box.putAll(entries);
      // await Future.wait(identifiables.map((i) => box.put(i.id, i.toJson())));
    } catch (e) {
      debugPrint("Error _saveMultiple<T> : box.put failed $e");
    }
  }

  Future<Anime?> getAnime(int id) async => await _get<Anime>(id);
  Future<Manga?> getManga(int id) async => await _get<Manga>(id);

  List<Anime> getAllAnime() => _getAll<Anime>();
  List<Manga> getAllManga() => _getAll<Manga>();

  Future<List<Anime>> getMultipleAnimes(List<int> ids) async =>
      await _getMultiples<Anime>(ids);

  Future<List<Manga>> getMultipleMangas(List<int> ids) async =>
      await _getMultiples<Manga>(ids);

  Future<void> saveAnime(Anime anime) async => await _save<Anime>(anime);
  Future<void> saveManga(Manga manga) async => await _save<Manga>(manga);

  Future<void> saveMultipleAnimes(List<Anime> animes) async =>
      await _saveMultiple<Anime>(animes);
  Future<void> saveMultipleMangas(List<Manga> mangas) async =>
      await _saveMultiple<Manga>(mangas);

  Future<List<T>> search<T extends Identifiable>({
    String? query,
    int page = 1,
    List<Genres>? genres,
    MediaStatus? status,
    MediaOrderBy? orderBy,
    AnimeType? animeType,
    AnimeRating? animeRating,
    MangaType? mangaType,
  }) async {
    Box box = getBoxByType<T>();
    List<T> result = [];
    final all = box.values;

    final String searchQuery = query?.toLowerCase().trim() ?? "";
    final bool hasGenreFilter = genres != null && genres.isNotEmpty;

    for (var identifiableMap in all) {
      T item = _fromJson(identifiableMap);

      // 1. Filtre TEXTE (Insensible à la casse)
      if (searchQuery.isNotEmpty) {
        if (!item.title.toLowerCase().contains(searchQuery)) {
          continue;
        }
      }
      if (hasGenreFilter) {
        List<Genres> itemGenres = item.genres;

        bool hasMatch = itemGenres.any((g) => genres.contains(g));
        if (!hasMatch) continue;
      }
      result.add(item);
    }

    if (orderBy != null) {
      switch (orderBy) {
        case MediaOrderBy.score:
          result.sort((a, b) {
            final sa = (a as Anime).score ?? 0.0;
            final sb = (b as Anime).score ?? 0.0;
            return sb.compareTo(sa);
          });
          break;
        default:
          break;
      }
    }

    final int totalResults = result.length;
    final int startIndex = (page - 1) * ITEM_PER_PAGE;

    if (startIndex > totalResults) {
      return [];
    }

    int endIndex = page * ITEM_PER_PAGE;
    if (endIndex > totalResults) {
      endIndex = totalResults;
    }
    return result.sublist(startIndex, endIndex);
  }
}
