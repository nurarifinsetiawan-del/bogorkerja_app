import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/taxonomy_model.dart';
import 'core_providers.dart';

final professionsProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final taxonomyResult =
      await ref.watch(taxonomyRepositoryProvider).getProfessions();

  return taxonomyResult.when(
    success: (data) => data,
    failure: (_) async {
      final homeResult =
          await ref.watch(homeRepositoryProvider).getHomeData();

      return homeResult.when(
        success: (home) => home.byProfession.cast<CategoryModel>(),
        failure: (_) => const <CategoryModel>[],
      );
    },
  );
});

final citiesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final taxonomyResult =
      await ref.watch(taxonomyRepositoryProvider).getCities();

  return taxonomyResult.when(
    success: (data) => data,
    failure: (_) async {
      final homeResult =
          await ref.watch(homeRepositoryProvider).getHomeData();

      return homeResult.when(
        success: (home) => home.byCity.cast<CategoryModel>(),
        failure: (_) => const <CategoryModel>[],
      );
    },
  );
});

/// Dipakai KHUSUS oleh picker "Minat Kota" di halaman Pengaturan. Beda dari
/// [citiesProvider] (yang cuma 2 nilai kasar "Kota Bogor"/"Kabupaten Bogor"
/// untuk filter Search) — provider ini granularitas kecamatan, SAMA dengan
/// target_city yang dipakai backend untuk mengirim & memfilter notifikasi.
/// Lihat catatan lengkap di TaxonomyRepository.getNotificationCities().
final notificationCitiesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final taxonomyResult =
      await ref.watch(taxonomyRepositoryProvider).getNotificationCities();

  return taxonomyResult.when(
    success: (data) => data,
    failure: (_) async {
      final homeResult =
          await ref.watch(homeRepositoryProvider).getHomeData();

      return homeResult.when(
        success: (home) => home.byCity.cast<CategoryModel>(),
        failure: (_) => const <CategoryModel>[],
      );
    },
  );
});

final companiesProvider = FutureProvider<List<CompanyModel>>((ref) async {
  final taxonomyResult =
      await ref.watch(taxonomyRepositoryProvider).getCompanies();

  return taxonomyResult.when(
    success: (data) => data,
    failure: (_) async {
      final homeResult =
          await ref.watch(homeRepositoryProvider).getHomeData();

      return homeResult.when(
        success: (home) => home.byCompany.cast<CompanyModel>(),
        failure: (_) => const <CompanyModel>[],
      );
    },
  );
});
