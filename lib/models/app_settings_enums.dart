enum AppSettingsKey {
  isFirstLaunch,
  autoSync,
  darkMode,
  isNotificationAllowed,
  isPersonalizedRecommendationAllowed,
  notificationTime,
  dataVersion,
  lastNotificationSent,
}

extension AppSettingsKeyX on AppSettingsKey {
  String get key => name;
}
