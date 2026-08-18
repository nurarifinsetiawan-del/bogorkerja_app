import 'package:flutter/material.dart';

import '../../../models/taxonomy_model.dart';
import '../../../theme/app_colors.dart';

/// Baris chip (wrap, semua item langsung terlihat tanpa scroll) untuk
/// section "Berdasarkan Profesi" & "Berdasarkan Kota" — tap chip navigasi
/// ke Search dengan filter ter-preset (lihat callback [onTap] dari HomeScreen).
class CategoryChipsRow extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel category) onTap;

  const CategoryChipsRow({super.key, required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in categories)
            ActionChip(
              onPressed: () => onTap(c),
              label: Text('${c.label} (${c.jobCount})'),
              backgroundColor: AppColors.primary.withValues(alpha: 0.06),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
              labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
