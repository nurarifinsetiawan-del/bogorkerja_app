import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/core_providers.dart';
import '../../providers/job_list_provider.dart';
import '../../repository/job_repository.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/job/job_card.dart';
import '../../widgets/job/job_card_shimmer.dart';
import '../home/home_screen.dart' show searchInitialFilterProvider;
import 'widgets/filter_bottom_sheet.dart';

/// Provider filter aktif untuk SearchScreen — dipisah dari jobListProvider
/// supaya UI (search bar, filter chip aktif) bisa reaktif terhadap
/// perubahan filter tanpa harus tahu detail pagination.
final activeSearchFilterProvider = StateProvider<JobFilter>((ref) => const JobFilter());

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Catat screen_view untuk GA4 supaya traffic dari app ikut tercatat
    // di Realtime, bukan cuma dari web.
    AnalyticsService.instance.logScreenView(
      screenName: '/all-jobs',
      screenClass: 'SearchScreen',
    );

    _scrollController.addListener(_onScroll);

    // Kalau datang dari Home (tap "Lihat Semua"/chip kategori), pakai
    // filter yang sudah di-set lewat searchInitialFilterProvider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = ref.read(searchInitialFilterProvider);
      if (initial != null) {
        ref.read(activeSearchFilterProvider.notifier).state = initial;
        ref.read(searchInitialFilterProvider.notifier).state = null;
        if (initial.query != null) _searchController.text = initial.query!;
      }
    });
  }

 void _onScroll() {
  if (!_scrollController.hasClients) return;

  final position = _scrollController.position;

  if (position.pixels >= position.maxScrollExtent - 300) {
    final filter = ref.read(activeSearchFilterProvider);
    final notifier = ref.read(jobListProvider(filter).notifier);

    notifier.loadMore();
  }
}

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      final current = ref.read(activeSearchFilterProvider);
      final newFilter = current.copyWith(query: value.isEmpty ? null : value);
      ref.read(activeSearchFilterProvider.notifier).state = newFilter;

      if (value.trim().isNotEmpty) {
        ref.read(recentSearchRepositoryProvider).add(value.trim());
      }
    });
  }

  Future<void> _openFilterSheet() async {
    final current = ref.read(activeSearchFilterProvider);
    final result = await showModalBottomSheet<JobFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterBottomSheet(initialFilter: current),
    );

    if (result != null) {
      ref.read(activeSearchFilterProvider.notifier).state =
          result.copyWith(query: current.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(activeSearchFilterProvider);
    final listState = ref.watch(jobListProvider(filter));
    final activeFilterCount = _countActiveFilters(filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lowongan'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onQueryChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari posisi, perusahaan...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                _onQueryChanged('');
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: _openFilterSheet,
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: const TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(jobListProvider(filter).notifier).refresh(),
              child: _buildBody(listState, filter),
            ),
          ),
        ],
      ),
    );
  }

  int _countActiveFilters(JobFilter f) {
    var count = 0;
    if (f.city != null) count++;
    if (f.profession != null) count++;
    if (f.employmentType != null) count++;
    if (f.education != null) count++;
    if (f.company != null) count++;
    if (f.sort == 'popular') count++;
    return count;
  }

  Widget _buildBody(JobListState state, JobFilter filter) {
    if (state.isLoadingFirstPage) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const JobCardShimmer(),
      );
    }

    if (state.errorMessage != null && state.jobs.isEmpty) {
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(jobListProvider(filter).notifier).loadFirstPage(),
      );
    }

    if (state.jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Tidak Ditemukan',
        message: 'Coba kata kunci lain atau ubah filter pencarian Anda.',
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.jobs.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= state.jobs.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return JobCard(job: state.jobs[index]);
      },
    );
  }
}
