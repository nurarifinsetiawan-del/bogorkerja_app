import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'providers/fcm_token_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage harus siap SEBELUM runApp karena beberapa provider
  // (theme, settings, bookmark) membaca Hive box secara synchronous saat
  // pertama kali di-build.
  await HiveService.instance.init();

  await initializeDateFormatting('id_ID', null);

  // Hanya init Firebase yang di-await di sini (cepat). Permission,
  // APNS, dan FCM token TIDAK boleh menahan first frame — di iOS
  // token APNS sering belum ada (apalagi Simulator) dan getToken()
  // bisa gagal / menggantung, yang kelihatan seperti black screen.
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 8));
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
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
  StreamSubscription<String>? _tokenRefreshSub;

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

    unawaited(_initPushAndAnalytics());

    // Cold start: app di-tap dari notification saat kondisi TERMINATED.
    // onMessage/onMessageOpenedApp di atas TIDAK menangkap kasus ini —
    // hanya getInitialMessage() yang tahu app dibuka lewat notification.
    // Navigasi ditunda ke frame berikutnya supaya GoRouter/navigator
    // sudah pasti ter-mount (menghindari "context belum siap").
    unawaited(_handleInitialMessage());
  }

  Future<void> _initPushAndAnalytics() async {
    try {
      final analytics = FirebaseAnalytics.instance;
      unawaited(analytics.setAnalyticsCollectionEnabled(true));
      unawaited(analytics.logAppOpen());

      await NotificationService.instance.init();
      if (!mounted) return;

      unawaited(ref.read(settingsProvider.notifier).syncInitialDevice());
      _tokenRefreshSub = NotificationService.instance.onTokenRefresh.listen((_) {
        unawaited(ref.read(settingsProvider.notifier).syncInitialDevice());
      });
      unawaited(_retryFcmRegistration());
    } catch (e) {
      debugPrint('Firebase/push init error: $e');
    }
  }

  /// APNS di iOS bisa datang beberapa detik setelah permission.
  /// Coba lagi di background; Simulator tidak pernah dapat token FCM.
  Future<void> _retryFcmRegistration() async {
    for (var i = 0; i < 2; i++) {
      if (i > 0) {
        await Future<void>.delayed(const Duration(seconds: 5));
      }
      if (!mounted) return;

      final token = await NotificationService.instance.getToken();
      if (token == null) continue;

      ref.invalidate(fcmTokenProvider);
      await ref.read(settingsProvider.notifier).syncInitialDevice();
      return;
    }
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
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
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
