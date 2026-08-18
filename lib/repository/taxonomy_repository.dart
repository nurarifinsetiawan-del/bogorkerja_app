import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/failures.dart';
import '../core/network/dio_client.dart';
import '../models/taxonomy_model.dart';

class TaxonomyRepository {
  final DioClient _client;

  TaxonomyRepository(this._client);

  Future<Result<List<CategoryModel>>> getProfessions() =>
      _getList<CategoryModel>(
        ApiConstants.professions,
        CategoryModel.fromJson,
      );

  Future<Result<List<CategoryModel>>> getCities() =>
      _getList<CategoryModel>(
        ApiConstants.cities,
        CategoryModel.fromJson,
      );

  /// Daftar kota untuk picker "Minat Kota" di Pengaturan — granularitas
  /// KECAMATAN (sama persis dengan target_city yang dipakai backend untuk
  /// mengirim & memfilter notifikasi). SENGAJA endpoint terpisah dari
  /// getCities() (yang cuma 2 nilai kasar "Kota Bogor"/"Kabupaten Bogor"
  /// untuk keperluan lain seperti filter Search) — kalau picker ini pakai
  /// getCities(), preferensi user nyaris tidak akan pernah match dengan
  /// notifikasi loker baru yang ditarget per kecamatan.
  Future<Result<List<CategoryModel>>> getNotificationCities() =>
      _getList<CategoryModel>(
        ApiConstants.notificationCities,
        CategoryModel.fromJson,
      );

  Future<Result<List<CompanyModel>>> getCompanies() =>
      _getList<CompanyModel>(
        ApiConstants.companies,
        CompanyModel.fromJson,
      );

  Future<Result<List<T>>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await _client.dio.get(
        path,
        // per_page: jaga-jaga kalau backend nge-paginate defaultnya kecil
        // (mis. 15), supaya list kategori/profesi tidak terpotong.
        queryParameters: {'per_page': 100},
      );

      final body = response.data as Map<String, dynamic>;
      final raw = body['data'];

      // Backend Laravel bisa balikin list polos (`{"data": [...]}`) ATAU
      // dibungkus paginator bawaan (`{"data": {"data": [...], "current_page": 1, ...}}`).
      // Tangani dua-duanya. Kalau bentuknya tidak dikenali sama sekali,
      // sengaja dilempar sebagai error (bukan list kosong) supaya provider
      // di atasnya fallback ke data home, bukan menampilkan kosong.
      final List rawList;
      if (raw is List) {
        rawList = raw;
      } else if (raw is Map && raw['data'] is List) {
        rawList = raw['data'] as List;
      } else {
        throw const FormatException('Bentuk response taxonomy tidak dikenali');
      }

      return Result.success(
        rawList
            .map(
              (e) => parser(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );
    } on DioException catch (_) {
      return const Result.failure(ServerFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }
}