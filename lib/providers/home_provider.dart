import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/failures.dart';
import '../models/home_data_model.dart';
import 'core_providers.dart';

/// AsyncNotifier menangani 3 state otomatis: loading, data, error — pas
/// untuk RefreshIndicator (pull to refresh cukup panggil ulang build()).
class HomeNotifier extends AsyncNotifier<HomeDataModel> {
  @override
  Future<HomeDataModel> build() async {
    return _fetch();
  }

  Future<HomeDataModel> _fetch() async {
    final repo = ref.watch(homeRepositoryProvider);
    final result = await repo.getHomeData();

    return result.when(
      success: (data) => data,
      failure: (f) => throw f,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeDataModel>(HomeNotifier.new);

/// Helper untuk menampilkan pesan error yang konsisten di seluruh app.
String failureMessage(Object error) {
  if (error is Failure) return error.message;
  return 'Terjadi kesalahan tak terduga.';
}
