enum AppSettingsKey {
  isFirstLaunch,
  autoSync,
  darkMode,
  isNotificationAllowed,
  isPersonalizedRecommendationAllowed,
  notificationTime,
  dataVersion,
}

extension AppSettingsKeyX on AppSettingsKey {
  String get key => name;
}
