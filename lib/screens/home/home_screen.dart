import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/taxonomy_model.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/home_provider.dart';
import '../../repository/job_repository.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/common/screen_view_logger.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/job/job_card.dart';
import '../../widgets/job/job_card_shimmer.dart';
import '../search/search_screen.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_chips_row.dart';
import 'widgets/company_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _goToSearchWithFilter(BuildContext context, WidgetRef ref, JobFilter filter) {
    ref.read(searchInitialFilterProvider.notifier).state = filter;
    context.goNamed(RouteNames.search);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);

    return ScreenViewLogger(
      screenName: '/',
      screenClass: 'HomeScreen',
      child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                child: homeAsync.when(
                  loading: () => _HomeLoadingSkeleton(),
                  error: (error, _) => ErrorState(
                    message: failureMessage(error),
                    onRetry: () => ref.read(homeProvider.notifier).refresh(),
                  ),
                  data: (home) => CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _HomeHeader(),
                      ),
                      if (home.banners.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: BannerCarousel(banners: home.banners),
                          ),
                        ),
                      if (home.latestJobs.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Lowongan Terbaru',
                            onSeeAll: () => _goToSearchWithFilter(
                              context, ref, const JobFilter(sort: 'latest'),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _HorizontalJobList(jobs: home.latestJobs),
                        ),
                      ],
                      if (home.popularJobs.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Lowongan Populer',
                            onSeeAll: () => _goToSearchWithFilter(
                              context, ref, const JobFilter(sort: 'popular'),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _HorizontalJobList(jobs: home.popularJobs),
                        ),
                      ],
                      if (home.byProfession.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: SectionHeader(title: 'Berdasarkan Profesi'),
                        ),
                        SliverToBoxAdapter(
                          child: CategoryChipsRow(
                            categories: home.byProfession,
                            onTap: (c) => _goToSearchWithFilter(
                              context, ref, JobFilter(profession: c.slug),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      ],
                      if (home.byCity.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: SectionHeader(title: 'Berdasarkan Kota'),
                        ),
                        SliverToBoxAdapter(
                          child: CategoryChipsRow(
                            categories: home.byCity,
                            onTap: (c) => _goToSearchWithFilter(
                              context, ref, JobFilter(city: c.label),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      ],
                      if (home.byCompany.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: SectionHeader(title: 'Berdasarkan Perusahaan'),
                        ),
                        SliverToBoxAdapter(
                          child: CompanyGrid(
                            companies: home.byCompany,
                            onTap: (c) => _goToSearchWithFilter(
                              context, ref, JobFilter(company: c.rawName ?? c.name),
                            ),
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang di',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalJobList extends StatelessWidget {
  final List jobs;
  const _HorizontalJobList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < jobs.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              JobCard(job: jobs[i], horizontal: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 92,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 165,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => const JobCardShimmer(horizontal: true),
          ),
        ),
      ],
    );
  }
}

/// State sementara untuk membawa filter awal dari Home ke Search saat
/// user tap "Lihat Semua" / chip kategori / logo perusahaan.
final searchInitialFilterProvider = StateProvider<JobFilter?>((ref) => null);
