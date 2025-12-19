import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/providers/settings_storage_provider.dart';

class SettingsRepositoryProvider {
  final SettingsStorage _storage;

  SettingsRepositoryProvider(this._storage);

  AppSettings getSettings() => _storage.load() ?? AppSettings();

  Future<void> updateSettings(AppSettings settings) async =>
      await _storage.save(settings);
}
