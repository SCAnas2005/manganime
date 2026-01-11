import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';

class SettingsRepositoryProvider {
  final SettingsStorage _storage;

  SettingsRepositoryProvider(this._storage);

  AppSettings getSettings() => _storage.load() ?? AppSettings();

  Future<void> updateSettings(AppSettings settings) async =>
      await _storage.save(settings);

  bool isSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
