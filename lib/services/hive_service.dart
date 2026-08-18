import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';

/// Titik akses tunggal ke semua Hive box. Semua data disimpan sebagai
/// JSON (Map/String) biasa — SENGAJA tidak memakai TypeAdapter hasil
/// build_runner supaya project ini tidak butuh proses code-generation
/// tambahan saat pertama kali di-setup (`hive.box<dynamic>` cukup).
class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  late Box<dynamic> bookmarksBox;
  late Box<dynamic> settingsBox;
  late Box<dynamic> recentSearchesBox;
  late Box<dynamic> readNotificationsBox;
  late Box<dynamic> homeCacheBox;

  Future<void> init() async {
    await Hive.initFlutter();

    bookmarksBox = await Hive.openBox(AppConstants.boxBookmarks);
    settingsBox = await Hive.openBox(AppConstants.boxSettings);
    recentSearchesBox = await Hive.openBox(AppConstants.boxRecentSearches);
    readNotificationsBox = await Hive.openBox(AppConstants.boxReadNotifications);
    homeCacheBox = await Hive.openBox(AppConstants.boxHomeCache);
  }
}
