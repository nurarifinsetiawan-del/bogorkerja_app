import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_detail_model.dart';
import 'core_providers.dart';

/// family by job id — AsyncNotifier otomatis re-fetch kalau id berubah
/// (mis. user pindah dari 1 job detail ke job detail lain via related jobs).
class JobDetailNotifier extends FamilyAsyncNotifier<JobDetailModel, int> {
  @override
  Future<JobDetailModel> build(int arg) async {
    final repo = ref.watch(jobRepositoryProvider);
    final result = await repo.getJobDetail(arg);

    return result.when(
      success: (data) => data,
      failure: (f) => throw f,
    );
  }
}

final jobDetailProvider =
    AsyncNotifierProvider.family<JobDetailNotifier, JobDetailModel, int>(JobDetailNotifier.new);

final relatedJobsProvider = FutureProvider.family((ref, int jobId) async {
  final repo = ref.watch(jobRepositoryProvider);
  final result = await repo.getRelatedJobs(jobId);
  return result.when(success: (data) => data, failure: (_) => const []);
});
