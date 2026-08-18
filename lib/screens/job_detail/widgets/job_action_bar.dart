import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../models/job_detail_model.dart';
import '../../../models/job_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../theme/app_colors.dart';

class JobActionBar extends ConsumerWidget {
  final JobDetailModel job;
  const JobActionBar({super.key, required this.job});

  Future<void> _handleApply(
  BuildContext context,
  HowToApply contact,
) async {
  String method = 'none';

  if (contact.whatsapp != null &&
      contact.whatsapp!.trim().isNotEmpty) {
    method = 'whatsapp';
  } else if (contact.link != null &&
      contact.link!.trim().isNotEmpty) {
    method = 'link';
  } else if (contact.email != null &&
      contact.email!.trim().isNotEmpty) {
    method = 'email';
  } else if (contact.phone != null &&
      contact.phone!.trim().isNotEmpty) {
    method = 'phone';
  }

  // Catat klik tombol Lamar ke Firebase Analytics.
  await FirebaseAnalytics.instance.logEvent(
    name: 'apply_job',
    parameters: {
      'job_id': job.id.toString(),
      'job_title': job.title,
      'company': job.company,
      'city': job.city,
      'method': method,
    },
  );

  if (contact.whatsapp != null &&
      contact.whatsapp!.trim().isNotEmpty) {
    var phone = contact.whatsapp!.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    // +628xxxxxxxxxx -> 628xxxxxxxxxx
    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    // 08xxxxxxxxxx -> 628xxxxxxxxxx
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    // Pastikan nomor Indonesia
    if (!phone.startsWith('62')) {
      phone = '62$phone';
    }

    final message = Uri.encodeComponent(
      'Halo, saya tertarik melamar posisi ${job.title} '
      'di ${job.company} yang saya lihat di ${AppConstants.appName}.',
    );

    final uri = Uri.parse(
      'https://wa.me/$phone?text=$message',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    return;
  }

  if (contact.link != null &&
      contact.link!.trim().isNotEmpty) {
    await launchUrl(
      Uri.parse(contact.link!),
      mode: LaunchMode.externalApplication,
    );
    return;
  }

  if (contact.email != null &&
      contact.email!.trim().isNotEmpty) {
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: contact.email,
        query: 'subject=${Uri.encodeComponent(
          'Lamaran Kerja - ${job.title}',
        )}',
      ),
    );
    return;
  }

  if (contact.phone != null &&
      contact.phone!.trim().isNotEmpty) {
    var phone = contact.phone!.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    if (phone.startsWith('+')) {
      phone = phone.substring(1);
    }

    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    await launchUrl(
      Uri(
        scheme: 'tel',
        path: phone,
      ),
    );

    return;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Informasi kontak lamaran tidak tersedia.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(
      bookmarkProvider.select((list) => list.any((j) => j.id == job.id)),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          _CircleActionButton(
            icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            active: isBookmarked,
            onTap: () {
              final jobForBookmark = JobModel.fromJson(job.toJobCardJson());
              ref.read(bookmarkProvider.notifier).toggle(jobForBookmark);
            },
          ),
          const SizedBox(width: 10),
          _CircleActionButton(
            icon: Icons.share_outlined,
            onTap: () => SharePlus.instance.share(
              ShareParams(
                text: 'Lowongan ${job.title} di ${job.company} - ${job.shareUrl}',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: job.isExpired ? null : () => _handleApply(context, job.howToApply),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(job.isExpired ? 'Lowongan Ditutup' : 'Lamar Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _CircleActionButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
        ),
        color: active ? AppColors.primary.withValues(alpha: 0.1) : null,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: active ? AppColors.primary : null),
      ),
    );
  }
}
