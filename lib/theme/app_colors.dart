import 'package:flutter/material.dart';

/// Palet warna tunggal untuk seluruh app. Warna utama biru-teal yang
/// terasa "profesional/trustworthy" (mirip nuansa job-portal populer)
/// tapi dengan identitas sendiri, bukan copy langsung dari brand lain.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0C3B4D); // navy dari logo Bogor Kerja
  static const Color primaryDark = Color(0xFF4FA3C7);
  static const Color secondary = Color(0xFF00B8A9); // teal aksen (badge, CTA sekunder)
  static const Color accent = Color(0xFFFF6B4A); // aksen hangat (badge "Baru", tombol Lamar)

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Light
  static const Color lightBackground = Color(0xFFF6F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E9F0);
  static const Color lightTextPrimary = Color(0xFF10151C);
  static const Color lightTextSecondary = Color(0xFF5C6B7A);

  // Dark
  static const Color darkBackground = Color(0xFF0E1116);
  static const Color darkSurface = Color(0xFF171B22);
  static const Color darkBorder = Color(0xFF2A2F3A);
  static const Color darkTextPrimary = Color(0xFFEDF1F7);
  static const Color darkTextSecondary = Color(0xFF9AA6B4);
}
