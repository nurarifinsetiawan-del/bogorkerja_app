import 'package:flutter/material.dart';

import '../../../models/job_detail_model.dart';

/// Grid 2 kolom menampilkan: Lokasi, Gaji, Pendidikan, Tipe Pekerjaan —
/// sesuai requirement "Pada Detail Lowongan tampilkan" di spesifikasi.
class JobInfoGrid extends StatelessWidget {
  final JobDetailModel job;
  const JobInfoGrid({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.location_on_outlined, 'Lokasi', job.address ?? job.city),
      (Icons.payments_outlined, 'Gaji', job.salary ?? 'Tidak disebutkan'),
      (
        Icons.school_outlined,
        'Pendidikan',
        job.education.isNotEmpty ? job.education.join(', ') : 'Tidak disebutkan',
      ),
      (Icons.work_outline_rounded, 'Tipe Pekerjaan', job.employmentTypeLabel),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _InfoRow(icon: items[i].$1, label: items[i].$2, value: items[i].$3),
              if (i != items.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
