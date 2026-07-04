import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),

    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),

      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),

      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),

      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),

      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textDark,
      ),

      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textGrey,
      ),

      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}