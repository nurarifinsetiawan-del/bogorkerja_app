import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../services/hive_service.dart';
import 'core_providers.dart';
import 'fcm_token_provider.dart';

class AppSettings {
  final String deviceId;
  final String? cityInterest;
  final String? professionInterest;
  final bool notificationsEnabled;

  const AppSettings({
    required this.deviceId,
    this.cityInterest,
    this.professionInterest,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    String? cityInterest,
    String? professionInterest,
    bool? notificationsEnabled,
    bool clearCity = false,
    bool clearProfession = false,
  }) {
    return AppSettings(
      deviceId: deviceId,
      cityInterest: clearCity ? null : (cityInterest ?? this.cityInterest),
      professionInterest: clearProfession ? null : (professionInterest ?? this.professionInterest),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Preferensi disimpan di Hive (persist antar sesi) & disinkronkan ke
/// backend lewat DeviceRepository setiap kali berubah, supaya push
/// notification yang diterima sesuai minat user.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final box = HiveService.instance.settingsBox;

    var deviceId = box.get(AppConstants.keyDeviceId) as String?;
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      box.put(AppConstants.keyDeviceId, deviceId);
    }

    // Pertama kali app dibuka (key belum pernah ditulis ke Hive) — nyalakan
    // notifikasi secara default dan simpan eksplisit, supaya "aktif saat
    // install pertama, user bisa matikan kapan saja lewat Pengaturan".
    var notificationsEnabled = box.get(AppConstants.keyNotificationsEnabled) as bool?;
    if (notificationsEnabled == null) {
      notificationsEnabled = true;
      box.put(AppConstants.keyNotificationsEnabled, true);
    }

    return AppSettings(
      deviceId: deviceId,
      cityInterest: box.get(AppConstants.keyCityInterest) as String?,
      professionInterest: box.get(AppConstants.keyProfessionInterest) as String?,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> syncInitialDevice() async {
  await _syncToServer();
}

  Future<void> updateCityInterest(String? city) async {
    final box = HiveService.instance.settingsBox;
    if (city == null) {
      await box.delete(AppConstants.keyCityInterest);
    } else {
      await box.put(AppConstants.keyCityInterest, city);
    }
    state = state.copyWith(cityInterest: city, clearCity: city == null);
    await _syncToServer();
  }

  Future<void> updateProfessionInterest(String? profession) async {
    final box = HiveService.instance.settingsBox;
    if (profession == null) {
      await box.delete(AppConstants.keyProfessionInterest);
    } else {
      await box.put(AppConstants.keyProfessionInterest, profession);
    }
    state = state.copyWith(professionInterest: profession, clearProfession: profession == null);
    await _syncToServer();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await HiveService.instance.settingsBox.put(AppConstants.keyNotificationsEnabled, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    await _syncToServer();
  }

  Future<void> _syncToServer() async {
    // PENTING: pakai `.future` (bukan `.value`) supaya kita benar-benar
    // MENUNGGU token FCM selesai diambil, bukan langsung memakai cache
    // yang mungkin masih null kalau fcmTokenProvider belum sempat
    // di-resolve di tempat lain (mis. user langsung buka Settings dan
    // toggle switch sebelum splash selesai registrasi token).
    // Kalau masih pakai `.value`, sync ini akan diam-diam gagal (silent
    // no-op) dan toggle "Aktifkan notifikasi" kelihatan ON di UI padahal
    // device TIDAK terdaftar di backend untuk menerima push notification.
    String? fcmToken;
    try {
      fcmToken = await ref.read(fcmTokenProvider.future);
    } catch (_) {
      fcmToken = null;
    }

    if (fcmToken == null) {
      // Token belum/tidak tersedia (izin notifikasi ditolak, Play
      // Services bermasalah, dll). Invalidate supaya percobaan
      // berikutnya (mis. user toggle lagi setelah aktifkan izin di
      // Pengaturan HP) memicu pengambilan token yang baru, bukan
      // stuck di hasil null yang lama selamanya.
      ref.invalidate(fcmTokenProvider);
      return;
    }

    await ref.read(deviceRepositoryProvider).registerDevice(
          deviceId: state.deviceId,
          fcmToken: fcmToken,
          platform: 'android',
          cityInterest: state.cityInterest,
          professionInterest: state.professionInterest,
          notificationsEnabled: state.notificationsEnabled,
        );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);