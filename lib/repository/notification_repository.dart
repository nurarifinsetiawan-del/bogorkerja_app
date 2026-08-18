import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/network/dio_client.dart';
import '../models/app_notification_model.dart';
import '../models/paginated_result.dart';
import '../services/hive_service.dart';

/// Status "sudah dibaca" disimpan lokal (Hive) per device — server tidak
/// tahu status baca karena tidak ada akun user (lihat catatan yang sama
/// di backend NotificationController).
class NotificationRepository {
  final DioClient _client;
  final _readBox = HiveService.instance.readNotificationsBox;

  NotificationRepository(this._client);

  Future<Result<PaginatedResult<AppNotificationModel>>> getNotifications({
    required String? deviceId,
    int page = 1,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          if (deviceId != null) 'device_id': deviceId,
        },
      );

      final json = response.data as Map<String, dynamic>;
      final result = PaginatedResult.fromJson(
        json,
        (item) => AppNotificationModel.fromJson(item, isRead: isRead(item['id'] as int)),
      );

      return Result.success(result);
    } on DioException catch (_) {
      return const Result.failure(ServerFailure('Gagal memuat notifikasi.'));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  bool isRead(int notificationId) => _readBox.containsKey(notificationId.toString());

  Future<void> markAsRead(int notificationId) async {
    await _readBox.put(notificationId.toString(), true);
  }

  int get unreadCountHint => 0; // dihitung di provider dari list yang sudah dimuat
}
