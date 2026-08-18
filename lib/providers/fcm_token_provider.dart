import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

/// Token FCM device saat ini. Dipisah ke file sendiri (bukan di dalam
/// notification_provider.dart) karena settings_provider.dart butuh
/// mengaksesnya juga, sementara notification_provider.dart butuh membaca
/// settingsProvider (device_id) — kalau digabung 1 file akan circular import.
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  return NotificationService.instance.getToken();
});
