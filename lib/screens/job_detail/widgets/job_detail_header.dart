import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/job_detail_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/job/job_age_badge.dart';

class JobDetailHeader extends StatelessWidget {
  final JobDetailModel job;

  const JobDetailHeader({
    super.key,
    required this.job,
  });

  String _normalizeImageUrl(String url) {
    final value = url.trim();

    if (value.isEmpty) return '';

    // Sudah URL lengkap
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    // URL relatif dari backend Laravel
    if (value.startsWith('/')) {
      return 'https://bogorkerja.id$value';
    }

    return 'https://bogorkerja.id/$value';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoUrl = job.logoUrl == null
        ? ''
        : _normalizeImageUrl(job.logoUrl!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl.isEmpty
                  ? const Icon(
                      Icons.apartment_rounded,
                      size: 30,
                    )
                  : CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.apartment_rounded,
                          size: 30,
                        );
                      },
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.company,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            JobAgeBadge(
              postedAt: job.postedAt,
              isExpired: job.isExpired,
            ),
            _InfoChip(
              icon: Icons.work_outline_rounded,
              label: job.employmentTypeLabel,
            ),
            if (job.isRecommended)
              const _InfoChip(
                icon: Icons.star_rounded,
                label: 'Rekomendasi',
                color: AppColors.accent,
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: c,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: c),
          ),
        ],
      ),
    );
  }
}
