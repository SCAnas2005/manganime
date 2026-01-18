// ignore_for_file: constant_identifier_names

import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/models/app_settings_enums.dart';
import 'package:flutter_application_1/models/identifiable_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorage {
  static const String SETTINGS_KEY = "settings";
  late final Box _box;

  static final SettingsStorage instance = SettingsStorage();

  Future<void> init() async {
    _box = await Hive.openBox(SETTINGS_KEY);
  }

  AppSettings? load() {
    if (_box.get(AppSettingsKey.isFirstLaunch.key) == null) return null;

    final rawGenres = _box.get(AppSettingsKey.favoriteGenres.key);
    List<String>? genreStrings;
    if (rawGenres != null) {
      genreStrings = (rawGenres as List).cast<String>();
    }

    return AppSettings(
      isFirstLaunch: _box.get(AppSettingsKey.isFirstLaunch.key),
      autoSync: _box.get(AppSettingsKey.autoSync.key),
      darkMode: _box.get(AppSettingsKey.darkMode.key),
      isNotificationAllowed: _box.get(AppSettingsKey.isNotificationAllowed.key),
      isPersonalizedRecommendationAllowed: _box.get(
        AppSettingsKey.isPersonalizedRecommendationAllowed.key,
      ),
      notificationTime: TimeOfDayX.fromMinutes(
        _box.get(AppSettingsKey.notificationTime.key) ?? 0,
      ),
      dataVersion: _box.get(AppSettingsKey.dataVersion.key) ?? 0,
      lastNotificationSent: _box.get(AppSettingsKey.lastNotificationSent.key),
      favoriteGenres: _favoriteGenresFromString(genreStrings),
    );
  }

  Future<void> save(AppSettings settings) async {
    await _box.put(AppSettingsKey.isFirstLaunch.key, settings.isFirstLaunch);
    await _box.put(AppSettingsKey.autoSync.key, settings.autoSync);
    await _box.put(AppSettingsKey.darkMode.key, settings.darkMode);
    await _box.put(
      AppSettingsKey.isNotificationAllowed.key,
      settings.isNotificationAllowed,
    );
    await _box.put(
      AppSettingsKey.isPersonalizedRecommendationAllowed.key,
      settings.isPersonalizedRecommendationAllowed,
    );

    if (settings.notificationTime != null) {
      await _box.put(
        AppSettingsKey.notificationTime.key,
        settings.notificationTime!.toMinutes(),
      );
    }

    await _box.put(AppSettingsKey.dataVersion.key, settings.dataVersion);
    await _box.put(
      AppSettingsKey.lastNotificationSent.key,
      settings.lastNotificationSent,
    );

    if (settings.favoriteGenres != null) {
      final genresToString = _favoriteGenresToString(settings.favoriteGenres!);
      await _box.put(AppSettingsKey.favoriteGenres.key, genresToString);
    }
  }

  List<String> _favoriteGenresToString(List<Genres> favorites) {
    return favorites.map((e) => e.toReadableString()).toList();
  }

  List<Genres> _favoriteGenresFromString(List<String>? favorites) {
    if (favorites == null) return [];
    // On filtre les nulls potentiels si le parsing échoue
    return favorites
        .map((e) => GenreX.fromString(e))
        .where((element) => element != null) // On retire les genres invalides
        .cast<Genres>() // On cast en liste propre
        .toList();
  }
}
