import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_model.dart';
import 'core_providers.dart';

/// Notifier sederhana yang membungkus BookmarkRepository (Hive, sync)
/// supaya UI reaktif — setiap add/remove langsung memicu rebuild di
/// semua widget yang watch provider ini (job card, tombol simpan di
/// detail, badge jumlah di halaman Simpan).
class BookmarkNotifier extends Notifier<List<JobModel>> {
  @override
  List<JobModel> build() {
    return ref.watch(bookmarkRepositoryProvider).getAll();
  }

  bool isBookmarked(int jobId) => state.any((j) => j.id == jobId);

  Future<void> toggle(JobModel job) async {
    final repo = ref.read(bookmarkRepositoryProvider);
    await repo.toggle(job);
    state = repo.getAll();
  }

  Future<void> remove(int jobId) async {
    final repo = ref.read(bookmarkRepositoryProvider);
    await repo.remove(jobId);
    state = repo.getAll();
  }
}

final bookmarkProvider = NotifierProvider<BookmarkNotifier, List<JobModel>>(BookmarkNotifier.new);
