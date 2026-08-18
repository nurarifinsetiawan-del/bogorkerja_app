import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_model.dart';
import '../repository/job_repository.dart';
import 'core_providers.dart';

class JobListState {
  final List<JobModel> jobs;
  final bool isLoadingFirstPage;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? errorMessage;

  const JobListState({
    this.jobs = const [],
    this.isLoadingFirstPage = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.errorMessage,
  });

  JobListState copyWith({
    List<JobModel>? jobs,
    bool? isLoadingFirstPage,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobListState(
      jobs: jobs ?? this.jobs,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Satu notifier per [JobFilter] (family) — jadi tiap kombinasi filter
/// (mis. kategori "admin" vs kota "Kota Bogor") punya state pagination
/// sendiri-sendiri, tidak saling menimpa.
class JobListNotifier extends FamilyNotifier<JobListState, JobFilter> {
  late JobFilter _filter;

  @override
  JobListState build(JobFilter arg) {
    _filter = arg;
    Future.microtask(loadFirstPage);
    return const JobListState(isLoadingFirstPage: true);
  }

  JobRepository get _repo => ref.read(jobRepositoryProvider);

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoadingFirstPage: true, clearError: true);

    final result = await _repo.getJobs(filter: _filter, page: 1);

    result.when(
      success: (paginated) {
        state = state.copyWith(
          jobs: paginated.items,
          isLoadingFirstPage: false,
          hasMore: paginated.hasMorePages,
          page: 1,
        );
      },
      failure: (f) {
        state = state.copyWith(isLoadingFirstPage: false, errorMessage: f.message);
      },
    );
  }

Future<void> loadMore() async {
  if (state.isLoadingMore ||
      state.isLoadingFirstPage ||
      !state.hasMore) {
    return;
  }

  final nextPage = state.page + 1;

  state = state.copyWith(
    isLoadingMore: true,
    clearError: true,
  );

  final result = await _repo.getJobs(
    filter: _filter,
    page: nextPage,
  );

  result.when(
    success: (paginated) {
      final existingIds = state.jobs.map((job) => job.id).toSet();

      final newJobs = paginated.items
          .where((job) => !existingIds.contains(job.id))
          .toList();

      state = state.copyWith(
        jobs: [...state.jobs, ...newJobs],
        isLoadingMore: false,
        hasMore: paginated.hasMorePages,
        page: nextPage,
      );
    },
    failure: (f) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: f.message,
      );
    },
  );
}

  Future<void> refresh() => loadFirstPage();

  /// Ganti filter tanpa membuat provider instance baru (dipakai saat user
  /// menambah/mengubah filter di layar yang sama, mis. Search dengan chip
  /// filter kota/profesi).
  Future<void> updateFilter(JobFilter newFilter) async {
    _filter = newFilter;
    await loadFirstPage();
  }
}

final jobListProvider =
    NotifierProvider.family<JobListNotifier, JobListState, JobFilter>(JobListNotifier.new);
