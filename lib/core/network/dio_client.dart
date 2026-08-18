import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Wrapper tunggal atas [Dio] untuk seluruh app. Semua repository
/// mengambil instance ini lewat Riverpod provider (lihat
/// providers/core_providers.dart), sehingga base URL, timeout, dan
/// interceptor konsisten di satu tempat.
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}',
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(_mapDioError(error));
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
        ),
      );
    }
  }

  DioException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return error.copyWith(error: const TimeoutException());
      case DioExceptionType.connectionError:
        return error.copyWith(error: const NetworkException());
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return error.copyWith(error: const NotFoundException());
        }
        final message = _extractServerMessage(error.response?.data) ??
            'Terjadi kesalahan pada server ($statusCode).';
        return error.copyWith(
          error: ServerException(message, statusCode: statusCode),
        );
      default:
        return error.copyWith(error: const AppException('Terjadi kesalahan tak terduga.'));
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
