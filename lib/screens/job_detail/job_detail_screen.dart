import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/home_provider.dart';
import '../../providers/job_detail_provider.dart';
import '../../services/analytics_service.dart';
import '../../widgets/common/error_state.dart';
import 'widgets/job_action_bar.dart';
import 'widgets/job_description_section.dart';
import 'widgets/job_detail_header.dart';
import 'widgets/job_info_grid.dart';
import 'widgets/related_jobs_section.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int jobId;

  const JobDetailScreen({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _analyticsLogged = false;

  Future<void> _logJobAnalytics(dynamic job) async {
  try {
    final analytics = AnalyticsService.instance;

    // 1. Catat screen_view untuk aplikasi
    final shareUri = Uri.tryParse(job.shareUrl.toString());

    final screenName = shareUri != null && shareUri.path.isNotEmpty
        ? shareUri.path
        : '/loker/${job.id}';

    await analytics.logJobScreen(
      jobId: job.id,
      screenName: screenName,
    );

    // 2. Catat event khusus lowongan
    await analytics.logViewJob(
      jobId: job.id,
      jobTitle: job.title.toString(),
      company: job.company.toString(),
      city: job.city.toString(),
    );

    debugPrint(
  '=== FIREBASE ANALYTICS JOB ===\n'
  'screen_view: $screenName\n'
  'job_id: ${job.id}\n'
  'title: ${job.title}\n'
  'source: app\n'
  '==============================',
);
  } catch (e) {
    debugPrint(
      'Firebase Analytics job gagal: $e',
    );
  }
}

  void _sendJobAnalyticsOnce(dynamic job) {
  if (_analyticsLogged) return;

  _analyticsLogged = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _logJobAnalytics(job);
  });
}

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(jobDetailProvider(widget.jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lowongan'),
        actions: [
          detailAsync.maybeWhen(
            data: (job) => IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      'Lowongan ${job.title} di ${job.company} - ${job.shareUrl}',
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => ErrorState(
          message: failureMessage(error),
          onRetry: () => ref.invalidate(
            jobDetailProvider(widget.jobId),
          ),
        ),
        data: (job) {
  _sendJobAnalyticsOnce(job);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    JobDetailHeader(job: job),
                    const SizedBox(height: 20),
                    JobInfoGrid(job: job),
                    const SizedBox(height: 24),
                    JobDescriptionSection(
                      description: job.description,
                      requirementsHtml: job.requirementsHtml,
                    ),
                    const SizedBox(height: 24),
                    RelatedJobsSection(jobId: job.id),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              JobActionBar(job: job),
            ],
          );
        },
      ),
    );
  }
}
