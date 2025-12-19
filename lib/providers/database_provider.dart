import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/anime.dart';
import 'package:flutter_application_1/models/identifiable.dart';
import 'package:flutter_application_1/models/manga.dart';
import 'package:flutter_application_1/providers/request_queue_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseProvider {
  static const String ANIMES_KEY = "animes_key";
  static const String MANGAS_KEY = "animes_key";

  static late final Box _animeBox;
  static late final Box _mangaBox;

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
    late List<T> list;

    // Seed minimal (bloquant)
    if (T == Anime) {
      list =
          await RequestQueue.instance.enqueue(
                () => service.getTopAnime(page: 1),
              )
              as List<T>;
    } else if (T == Manga) {
      list =
          await RequestQueue.instance.enqueue(
                () => service.getTopManga(page: 1),
              )
              as List<T>;
      throw UnsupportedError('Type $T non supporté');
    } else {
      throw UnsupportedError('Type $T non supporté');
    }

    await instance._saveMultiple<T>(list);

    // Seed complet en arrière-plan
    final int totalPages = (total / 25).ceil();

    Future.microtask(() async {
      for (int page = 2; page <= totalPages; page++) {
        if (T == Anime) {
          list =
              await RequestQueue.instance.enqueue(
                    () => service.getTopAnime(page: page),
                  )
                  as List<T>;
        } else if (T == Manga) {
          list =
              await RequestQueue.instance.enqueue(
                    () => service.getTopManga(page: page),
                  )
                  as List<T>;
          throw UnsupportedError('Type $T non supporté');
        }

        await instance._saveMultiple<T>(list);
      }

      debugPrint(
        "Database populate ended. Database length : ${instance.length<T>()}",
      );
    });
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

  Future<T?> _get<T extends Identifiable>(int id) async {
    Box box = getBoxByType<T>();
    final Map<String, dynamic>? raw = await box.get(id);

    if (raw == null) return null;

    if (T is Anime) return Anime.fromJson(raw) as T;
    if (T is Manga) return Manga.fromJson(raw) as T;

    throw UnsupportedError('Type $T not supported');
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
      await Future.wait(identifiables.map((i) => box.put(i.id, i.toJson())));
    } catch (e) {
      debugPrint("Error _saveMultiple<T> : box.put failed $e");
    }
  }

  Future<Anime?> getAnime(int id) => _get<Anime>(id);
  Future<Manga?> getManga(int id) => _get<Manga>(id);

  Future<void> saveAnime(Anime anime) => _save<Anime>(anime);
  Future<void> saveManga(Manga manga) => _save<Manga>(manga);

  Future<void> saveMultipleAnimes(List<Anime> animes) =>
      _saveMultiple<Anime>(animes);
  Future<void> saveMultipleMangas(List<Manga> mangas) =>
      _saveMultiple<Manga>(mangas);
}
