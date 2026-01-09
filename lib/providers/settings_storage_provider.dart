import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/models/app_settings_enums.dart';
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
  }
}
