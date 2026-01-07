import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/app_settings.dart';
import 'package:flutter_application_1/providers/settings_repository_provider.dart';

class AppSettingsViewModel extends ChangeNotifier {
  final SettingsRepositoryProvider _settingsRepository;
  late AppSettings settings;
  bool loaded = false;

  AppSettingsViewModel(this._settingsRepository);

  Future<void> init() async {
    settings = _settingsRepository.getSettings();
    loaded = true;
    notifyListeners();
  }

  Future<void> toggleDarkMode({bool? value}) async {
    settings = settings = settings.copyWith(
      darkMode: value ?? !settings.darkMode,
    );
    notifyListeners();
    await _settingsRepository.updateSettings(
      settings.copyWith(darkMode: value ?? !settings.darkMode),
    );
  }

  Future<void> toggleAutoSync({bool? value}) async {}
}
