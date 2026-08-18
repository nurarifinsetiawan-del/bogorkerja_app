import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/errors/failures.dart';
import '../core/network/dio_client.dart';import '../models/job_detail_model.dart';
import '../models/job_model.dart';
import '../models/paginated_result.dart';

/// Filter untuk `GET /jobs`, dibuat sebagai class terpisah supaya
/// pemanggilan dari SearchScreen tetap type-safe (bukan Map bebas) dan
/// mudah di-cache sebagai bagian dari Riverpod provider key.
const _unset = Object();

class JobFilter {
  final String? query;
  final String? city;
  final String? profession;
  final String? employmentType;
  final String? education;
  final String? company;
  final String sort;

  const JobFilter({
    this.query,
    this.city,
    this.profession,
    this.employmentType,
    this.education,
    this.company,
    this.sort = 'latest',
  });

  JobFilter copyWith({
    Object? query = _unset,
    Object? city = _unset,
    Object? profession = _unset,
    Object? employmentType = _unset,
    Object? education = _unset,
    Object? company = _unset,
    String? sort,
  }) {
    return JobFilter(
      query: identical(query, _unset) ? this.query : query as String?,
      city: identical(city, _unset) ? this.city : city as String?,
      profession: identical(profession, _unset)
          ? this.profession
          : profession as String?,
      employmentType: identical(employmentType, _unset)
          ? this.employmentType
          : employmentType as String?,
      education: identical(education, _unset)
          ? this.education
          : education as String?,
      company: identical(company, _unset)
          ? this.company
          : company as String?,
      sort: sort ?? this.sort,
    );
  }

  bool get isEmpty =>
      query == null &&
      city == null &&
      profession == null &&
      employmentType == null &&
      education == null &&
      company == null;

  Map<String, dynamic> toQueryParams({int page = 1, int perPage = 15}) {
    return {
      'page': page,
      'per_page': perPage,
      'sort': sort,
      if (query != null && query!.isNotEmpty) 'q': query,
      if (city != null) 'city': city,
      if (profession != null) 'profession': profession,
      if (employmentType != null) 'employment_type': employmentType,
      if (education != null) 'education': education,
      if (company != null) 'company': company,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is JobFilter &&
      other.query == query &&
      other.city == city &&
      other.profession == profession &&
      other.employmentType == employmentType &&
      other.education == education &&
      other.company == company &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
        query, city, profession, employmentType, education, company, sort,
      );
}

class JobRepository {
  final DioClient _client;

  JobRepository(this._client);

  Future<Result<PaginatedResult<JobModel>>> getJobs({
    required JobFilter filter,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _client.dio.get(
  ApiConstants.jobs,
  queryParameters: filter.toQueryParams(
    page: page,
    perPage: perPage,
  ),
);

debugPrint(
  'GET JOBS => page=$page, perPage=$perPage, '
  'items=${(response.data['data'] as List?)?.length}',
);

      return Result.success(
        PaginatedResult.fromJson(response.data as Map<String, dynamic>, JobModel.fromJson),
      );
    } on DioException catch (e) {
      return Result.failure(_toFailure(e));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  Future<Result<JobDetailModel>> getJobDetail(int id) async {
    try {
      final response = await _client.dio.get(ApiConstants.jobDetail(id));
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return Result.success(JobDetailModel.fromJson(data));
    } on DioException catch (e) {
      return Result.failure(_toFailure(e));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  Future<Result<List<JobModel>>> getRelatedJobs(int id) async {
    try {
      final response = await _client.dio.get(ApiConstants.jobRelated(id));
      final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return Result.success(
        data.map((e) => JobModel.fromJson((e as Map).cast<String, dynamic>())).toList(),
      );
    } on DioException catch (e) {
      return Result.failure(_toFailure(e));
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  Failure _toFailure(DioException e) {
    final error = e.error;
    if (error is NetworkException || error is TimeoutException) {
      return NetworkFailure(error is AppException ? error.message : 'Tidak ada koneksi internet.');
    }
    if (error is NotFoundException) {
      return NotFoundFailure(error.message);
    }
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    return const UnknownFailure();
  }
}
