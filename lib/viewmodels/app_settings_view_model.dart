import 'package:flutter/material.dart';

class AppSettings {
  bool darkMode;
  bool notificationsEnabled;
  bool dailySuggestions;
  TimeOfDay notificationTime;
  Set<String> selectedGenres;

  AppSettings({
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.dailySuggestions = true,
    this.notificationTime = const TimeOfDay(hour: 9, minute: 0),
    Set<String>? selectedGenres,
  }) : selectedGenres = selectedGenres ?? {'Action', 'Shōnen'};
}

class AppSettingsViewModel extends ChangeNotifier {
  bool _loaded = false;
  bool get loaded => _loaded;

  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  AppSettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Simuler un chargement (peut être remplacé par SharedPreferences, Hive, etc.)
    await Future.delayed(const Duration(milliseconds: 100));
    _loaded = true;
    notifyListeners();
  }

  void toggleDarkMode({required bool value}) {
    _settings.darkMode = value;
    notifyListeners();
  }

  void toggleNotifications({required bool value}) {
    _settings.notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDailySuggestions({required bool value}) {
    _settings.dailySuggestions = value;
    notifyListeners();
  }

  void setNotificationTime(TimeOfDay time) {
    _settings.notificationTime = time;
    notifyListeners();
  }

  void toggleGenre(String genre) {
    if (_settings.selectedGenres.contains(genre)) {
      _settings.selectedGenres.remove(genre);
    } else {
      _settings.selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void resetSettings() {
    _settings = AppSettings();
    notifyListeners();
  }
}
