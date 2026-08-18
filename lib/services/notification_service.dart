import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Membungkus firebase_messaging + flutter_local_notifications.
/// firebase_messaging saja TIDAK menampilkan notifikasi visual saat app
/// sedang dibuka (foreground) di Android — makanya perlu
/// flutter_local_notifications untuk menampilkannya secara manual saat
/// pesan foreground diterima.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'job_alerts', // id — HARUS sama dengan yang didaftarkan di AndroidManifest kalau override
    'Info Loker',
    description: 'Notifikasi loker baru sesuai minat Anda',
    importance: Importance.high,
  );

  static String get devicePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// Callback dipanggil saat notifikasi (foreground/background/tap) berisi
  /// job_id, supaya main.dart bisa navigasi ke JobDetailScreen lewat GoRouter.
  void Function(int jobId)? onJobNotificationTap;

  /// Dipanggil setiap kali ada push masuk saat app terbuka (foreground),
  /// supaya main.dart bisa refresh provider tab Notifikasi — jadi list-nya
  /// ikut update otomatis tanpa user perlu tarik-refresh manual.
  void Function()? onNewNotificationReceived;

  Future<void> init() async {
    if (_initialized) return;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final jobId = response.payload;
        if (jobId != null) {
          onJobNotificationTap?.call(int.tryParse(jobId) ?? 0);
        }
      },
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final jobId = message.data['job_id'];
      if (jobId != null) {
        onJobNotificationTap?.call(int.tryParse(jobId.toString()) ?? 0);
      }
    });

    _initialized = true;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['job_id']?.toString(),
    );

    onNewNotificationReceived?.call();
  }

  /// Returns the FCM token, or null if it is not ready yet.
  ///
  /// On iOS, [FirebaseMessaging.getToken] throws
  /// `apns-token-not-set` until APNS has delivered a token (often never
  /// on Simulator). We check APNS first and time out so callers never
  /// hang the UI.
  Future<String?> getToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging
            .getAPNSToken()
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
        if (apnsToken == null) {
          if (kDebugMode) {
            debugPrint('APNS token not ready yet; skipping FCM getToken');
          }
          return null;
        }
      }

      return await _messaging
          .getToken()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
    } catch (e) {
      if (kDebugMode) debugPrint('FCM getToken error: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}

/// Handler untuk pesan yang masuk saat app di background/terminated.
/// HARUS berupa top-level function (bukan method di class), sesuai
/// requirement package firebase_messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp() sudah dipanggil ulang di sini oleh package
  // saat isolate background baru dibuat — tidak perlu logic tambahan
  // untuk kasus dasar (notifikasi otomatis tetap tampil dari sistem).
}
