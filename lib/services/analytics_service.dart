import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logViewJob({
    required int jobId,
    required String jobTitle,
    String? company,
    String? city,
  }) async {
    await _analytics.logEvent(
      name: 'view_job',
      parameters: {
        'job_id': jobId.toString(),
        'job_title': jobTitle,
        if (company != null && company.isNotEmpty) 'company': company,
        if (city != null && city.isNotEmpty) 'city': city,
        'source': 'app',
      },
    );
  }

  Future<void> logJobScreen({
    required int jobId,
    required String screenName,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: 'JobDetailScreen',
    );
  }

  /// Catat `screen_view` generik untuk halaman non-loker (Beranda, Semua
  /// Loker, Simpan, Notifikasi, Profil, Pengaturan, Onboarding).
  ///
  /// Sebelumnya hanya halaman detail loker yang mengirim `screen_view`,
  /// sehingga di GA4 Realtime ("Halaman dan kelompok tampilan") hanya
  /// traffic dari website yang terlihat — traffic dari aplikasi tidak
  /// tersistem karena memang belum pernah dikirim. `screenName` dibuat
  /// meniru pola path di web (mis. "/", "/all-jobs") supaya kedua sumber
  /// tergabung rapi di laporan yang sama.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      // Jangan sampai kegagalan logging analytics mengganggu UI.
    }
  }
}