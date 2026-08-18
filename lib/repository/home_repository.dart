import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/errors/failures.dart';
import '../core/network/dio_client.dart';
import '../models/home_data_model.dart';

class HomeRepository {
  final DioClient _client;

  HomeRepository(this._client);

  Future<Result<HomeDataModel>> getHomeData() async {
    try {
      final response = await _client.dio.get(ApiConstants.home);
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return Result.success(HomeDataModel.fromJson(data));
    } on DioException catch (e) {
      final error = e.error;
      if (error is NetworkException || error is TimeoutException) {
        return const Result.failure(NetworkFailure());
      }
      if (error is ServerException) {
        return Result.failure(ServerFailure(error.message));
      }
      return const Result.failure(UnknownFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }
}
