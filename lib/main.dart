import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'providers/notification_provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'routes/route_names.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage harus siap SEBELUM runApp karena beberapa provider
  // (theme, settings, bookmark) membaca Hive box secara synchronous saat
  // pertama kali di-build.
  await HiveService.instance.init();

  await initializeDateFormatting('id_ID', null);

  // Firebase & push notification: dibungkus try-catch supaya app tetap
  // bisa jalan (tanpa fitur push) kalau google-services.json belum
  // di-setup saat development awal, bukan crash total.
  try {
  await Firebase.initializeApp();

  final analytics = FirebaseAnalytics.instance;

  await analytics.setAnalyticsCollectionEnabled(true);
  await analytics.logAppOpen();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await NotificationService.instance.init();
} catch (e) {
  debugPrint('Firebase belum siap / gagal init: $e');
}

  runApp(const ProviderScope(child: BogorKerjaApp()));
}

class BogorKerjaApp extends ConsumerStatefulWidget {
  const BogorKerjaApp({super.key});

  @override
  ConsumerState<BogorKerjaApp> createState() => _BogorKerjaAppState();
}

class _BogorKerjaAppState extends ConsumerState<BogorKerjaApp> {
  @override
  void initState() {
    super.initState();

    // Tap notifikasi (foreground/background) -> navigasi langsung ke
    // JobDetailScreen lewat GoRouter, di luar widget tree biasa.
    NotificationService.instance.onJobNotificationTap = (jobId) {
      if (jobId > 0) {
        final router = ref.read(goRouterProvider);
        router.pushNamed(RouteNames.jobDetail, pathParameters: {'id': jobId.toString()});
      }
    };

    // Ada push baru masuk saat app terbuka -> refresh tab Notifikasi
    // supaya list-nya langsung update tanpa user perlu tarik-refresh manual.
    NotificationService.instance.onNewNotificationReceived = () {
      ref.read(notificationFeedProvider.notifier).silentRefresh();
    };

    // Cold start: app di-tap dari notification saat kondisi TERMINATED.
    // onMessage/onMessageOpenedApp di atas TIDAK menangkap kasus ini —
    // hanya getInitialMessage() yang tahu app dibuka lewat notification.
    // Navigasi ditunda ke frame berikutnya supaya GoRouter/navigator
    // sudah pasti ter-mount (menghindari "context belum siap").
    _handleInitialMessage();
  }

  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      final jobId = initialMessage?.data['job_id'];
      if (jobId == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.instance.onJobNotificationTap
            ?.call(int.tryParse(jobId.toString()) ?? 0);
      });
    } catch (e) {
      debugPrint('getInitialMessage error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
