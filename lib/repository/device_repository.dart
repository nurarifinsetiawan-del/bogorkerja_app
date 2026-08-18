import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/network/dio_client.dart';

class DeviceRepository {
  final DioClient _client;

  DeviceRepository(this._client);

  Future<Result<bool>> registerDevice({
    required String deviceId,
    required String fcmToken,
    required String platform,
    String? cityInterest,
    String? professionInterest,
    bool notificationsEnabled = true,
  }) async {
    try {
      await _client.dio.post(ApiConstants.devices, data: {
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'platform': platform,
        'city_interest': cityInterest,
        'profession_interest': professionInterest,
        'notifications_enabled': notificationsEnabled,
      });
      return const Result.success(true);
    } on DioException catch (_) {
      return const Result.failure(ServerFailure('Gagal mendaftarkan perangkat untuk notifikasi.'));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  Future<void> unregisterDevice(String deviceId) async {
    try {
      await _client.dio.delete('${ApiConstants.devices}/$deviceId');
    } catch (_) {
      // Best-effort saja — tidak kritikal kalau gagal.
    }
  }
}
