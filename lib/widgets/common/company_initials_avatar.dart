import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Fallback tampilan saat logo perusahaan tidak tersedia (null/kosong)
/// atau gagal dimuat dari server. Dipakai di JobCard & CompanyGrid supaya
/// tampilannya terasa "disengaja" (avatar inisial berwarna) daripada
/// ikon gedung generik yang terkesan seperti gambar rusak/error.
///
/// Warna dipilih deterministik dari nama perusahaan (hash sederhana),
/// jadi perusahaan yang sama akan selalu dapat warna yang sama.
class CompanyInitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const CompanyInitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
  });

  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    Color(0xFF6D5CD3), // ungu pelengkap
    Color(0xFF2E7D6B), // hijau tua pelengkap
  ];

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, words.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  Color get _bgColor {
    final hash = name.trim().toLowerCase().codeUnits.fold<int>(0, (acc, c) => acc + c);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: _bgColor.withValues(alpha: 0.12),
      child: Text(
        _initials,
        style: TextStyle(
          color: _bgColor,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
