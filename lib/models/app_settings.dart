import 'package:flutter/material.dart';

class AppSettings {
  bool isFirstLaunch;
  bool darkMode;
  bool autoSync;
  bool isNotificationAllowed;
  bool isPersonalizedRecommendationAllowed;
  TimeOfDay? notificationTime;

  final int dataVersion;

  AppSettings({
    this.isFirstLaunch = true,
    this.autoSync = false,
    this.darkMode = false,
    this.isNotificationAllowed = false,
    this.isPersonalizedRecommendationAllowed = false,
    this.dataVersion = 0,
    this.notificationTime,
  }) {
    notificationTime = isNotificationAllowed
        ? TimeOfDay(hour: 9, minute: 0)
        : (notificationTime ?? TimeOfDay(hour: 0, minute: 0));
  }

  AppSettings copyWith({
    bool? isFirstLaunch,
    bool? autoSync,
    bool? darkMode,
    bool? isNotificationAllowed,
    bool? isPersonalizedRecommendationAllowed,
    TimeOfDay? notificationTime,
    int? dataVersion,
  }) {
    return AppSettings(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      autoSync: autoSync ?? this.autoSync,
      darkMode: darkMode ?? this.darkMode,
      isNotificationAllowed:
          isNotificationAllowed ?? this.isNotificationAllowed,
      isPersonalizedRecommendationAllowed:
          isPersonalizedRecommendationAllowed ??
          this.isPersonalizedRecommendationAllowed,
      notificationTime: notificationTime ?? this.notificationTime,
      dataVersion: dataVersion ?? this.dataVersion,
    );
  }
}

extension TimeOfDayX on TimeOfDay {
  int toMinutes() => hour * 60 + minute;

  static TimeOfDay fromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
