import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/job_model.dart';
import '../../providers/bookmark_provider.dart';
import '../../routes/route_names.dart';
import '../../theme/app_colors.dart';
import '../common/company_initials_avatar.dart';
import 'job_age_badge.dart';

/// Kartu lowongan standar — dipakai di list Home (horizontal & vertical),
/// hasil Search, dan Bookmark. Style konsisten: logo, judul, perusahaan,
/// lokasi, gaji, badge tipe kerja/rekomendasi, tombol simpan cepat.
class JobCard extends ConsumerWidget {
  final JobModel job;
  final bool horizontal;
  final String source;

 const JobCard({
  super.key,
  required this.job,
  this.horizontal = false,
  this.source = 'home',
});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBookmarked = ref.watch(bookmarkProvider.select(
      (list) => list.any((j) => j.id == job.id),
    ));
    final showAccent = horizontal && job.isRecommended;

    return SizedBox(
      width: horizontal ? 258 : double.infinity,
      child: Container(
        decoration: horizontal
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              )
            : null,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: horizontal
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                )
              : null,
          child: InkWell(
            onTap: () => context.pushNamed(
  RouteNames.jobDetail,
  pathParameters: {'id': job.id.toString()},
  queryParameters: {'source': source},
),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showAccent)
                  const SizedBox(
                    height: 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.secondary],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CompanyLogo(url: job.logoUrl, companyName: job.company),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  job.company,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor: isBookmarked
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              padding: const EdgeInsets.all(6),
                            ),
                            onPressed: () => ref.read(bookmarkProvider.notifier).toggle(job),
                            icon: Icon(
                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 20,
                              color: isBookmarked ? AppColors.primary : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.outline),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.city,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (job.salary != null && job.salary!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payments_outlined, size: 13, color: AppColors.success),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  job.salary!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          JobAgeBadge(postedAt: job.postedAt, isExpired: job.isExpired),
                          _MiniChip(label: job.employmentTypeLabel),
                          if (job.isRecommended)
                            const _MiniChip(label: 'Rekomendasi', color: AppColors.accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? url;
  final String companyName;
  const _CompanyLogo({this.url, required this.companyName});

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    final fallback = CompanyInitialsAvatar(name: companyName, size: 44);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
        clipBehavior: Clip.antiAlias,
        child: (url == null || url!.isEmpty)
            ? fallback
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (context, _) => const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, _, __) => fallback,
              ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _MiniChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c),
      ),
    );
  }
}
