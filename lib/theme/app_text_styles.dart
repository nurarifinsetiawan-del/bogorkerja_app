import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale terpusat memakai Plus Jakarta Sans — font modern,
/// mudah dibaca di ukuran kecil (penting untuk card lowongan yang padat
/// informasi), dan gratis lewat google_fonts.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 28, fontWeight: FontWeight.w800, color: primaryTextColor, height: 1.2,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: primaryTextColor, height: 1.25,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w700, color: primaryTextColor, height: 1.3,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w700, color: primaryTextColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: primaryTextColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: primaryTextColor, height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13.5, fontWeight: FontWeight.w400, color: secondaryTextColor, height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondaryTextColor, height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: primaryTextColor,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 11.5, fontWeight: FontWeight.w600, color: secondaryTextColor,
      ),
    );
  }
}
