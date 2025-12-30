enum AppSettingsKey {
  isFirstLaunch,
  autoSync,
  darkMode,
  isNotificationAllowed,
  isPersonalizedRecommendationAllowed,
  notificationTime,
}

extension AppSettingsKeyX on AppSettingsKey {
  String get key => name;
}
