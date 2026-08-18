import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/job_detail_provider.dart';
import '../../../widgets/job/job_card.dart';

class RelatedJobsSection extends ConsumerWidget {
  final int jobId;

  const RelatedJobsSection({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedJobsProvider(jobId));
    final theme = Theme.of(context);

    return relatedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (jobs) {
        if (jobs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lowongan Terkait',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 4),
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
            ),
          ],
        );
      },
    );
  }
}
