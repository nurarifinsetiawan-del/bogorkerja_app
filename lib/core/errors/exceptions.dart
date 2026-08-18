/// Exception khusus dari layer network (dipakai di DioClient interceptor),
/// dikonversi jadi [Failure] di layer repository supaya UI tidak perlu
/// tahu detail teknis Dio.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Tidak ada koneksi internet. Periksa jaringan Anda.'])
      : super(message);
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'Koneksi timeout. Coba lagi.'])
      : super(message);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Data tidak ditemukan.'])
      : super(message, statusCode: 404);
}
