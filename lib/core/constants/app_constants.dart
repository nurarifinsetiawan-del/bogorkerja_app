class AppConstants {
  AppConstants._();

  static const String appName = 'Bogor Kerja ID';
  static const String appTagline = 'Cari kerja di Bogor jadi lebih mudah';

  // Hive box names
  static const String boxBookmarks = 'bookmarks_box';
  static const String boxSettings = 'settings_box';
  static const String boxRecentSearches = 'recent_searches_box';
  static const String boxReadNotifications = 'read_notifications_box';
  static const String boxHomeCache = 'home_cache_box';

  // Shared preferences / settings keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyDeviceId = 'device_id';
  static const String keyCityInterest = 'city_interest';
  static const String keyProfessionInterest = 'profession_interest';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyOnboardingSeen = 'onboarding_seen';

  static const int recentSearchLimit = 8;
  static const int jobsPerPage = 15;
}
