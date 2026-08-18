import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Replikasi logic badge umur lowongan dari backend (JobHelper::ageBadgeHtml)
/// supaya tampilan app konsisten dengan website.
class JobAgeBadge extends StatelessWidget {
  final DateTime? postedAt;
  final bool isExpired;

  const JobAgeBadge({super.key, this.postedAt, this.isExpired = false});

  @override
  Widget build(BuildContext context) {
    if (isExpired) {
      return _badge(context, 'Tutup', Colors.grey);
    }

    if (postedAt == null) {
      return _badge(context, 'Baru', AppColors.secondary);
    }

    final ageDays = DateTime.now().difference(postedAt!).inDays;

    String label;
    Color color;

    if (ageDays == 0) {
      label = 'Hari Ini';
      color = AppColors.accent;
    } else if (ageDays <= 3) {
      label = 'Baru';
      color = AppColors.secondary;
    } else if (ageDays < 7) {
      label = '$ageDays Hari';
      color = Colors.blueGrey;
    } else if (ageDays < 30) {
      label = '${(ageDays / 7).floor()} Minggu';
      color = Colors.blueGrey;
    } else {
      label = '${(ageDays / 30).floor()} Bulan';
      color = Colors.blueGrey;
    }

    return _badge(context, label, color);
  }

  Widget _badge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
