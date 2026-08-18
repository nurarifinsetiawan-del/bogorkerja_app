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

  static const _channel = AndroidNotificationChannel(
    'job_alerts', // id — HARUS sama dengan yang didaftarkan di AndroidManifest kalau override
    'Info Loker',
    description: 'Notifikasi loker baru sesuai minat Anda',
    importance: Importance.high,
  );

  /// Callback dipanggil saat notifikasi (foreground/background/tap) berisi
  /// job_id, supaya main.dart bisa navigasi ke JobDetailScreen lewat GoRouter.
  void Function(int jobId)? onJobNotificationTap;

  /// Dipanggil setiap kali ada push masuk saat app terbuka (foreground),
  /// supaya main.dart bisa refresh provider tab Notifikasi — jadi list-nya
  /// ikut update otomatis tanpa user perlu tarik-refresh manual.
  void Function()? onNewNotificationReceived;

  Future<void> init() async {
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

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
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
