/// Konstanta terkait koneksi ke backend Laravel.
///
/// PENTING: [baseUrl] dipisah dari path API supaya mudah diganti saat
/// pindah environment (staging/production) tanpa menyentuh kode lain.
/// Ganti lewat --dart-define saat build kalau perlu multi-environment,
/// contoh:
///   flutter build apk --dart-define=API_BASE_URL=https://staging.bogorkerja.id
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bogorkerja.id',
  );

  static const String apiPrefix = '/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints (relatif terhadap apiPrefix)
  static const String home = '/home';
  static const String jobs = '/jobs';
  static String jobDetail(int id) => '/jobs/$id';
  static String jobRelated(int id) => '/jobs/$id/related';
  static const String professions = '/professions';
  static const String cities = '/cities';
  static const String notificationCities = '/notification-cities';
  static const String companies = '/companies';
  static const String devices = '/devices';
  static const String notifications = '/notifications';
}
