import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: AppColors.lightText,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        color: AppColors.lightTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.inter(
        color: AppColors.lightTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(color: AppColors.lightText),
      bodyMedium: GoogleFonts.inter(color: AppColors.lightText),
      bodySmall: GoogleFonts.inter(color: AppColors.lightTextSecondary),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.lightText,
      onError: AppColors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.lightText),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
    ),

    iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.lightTextSecondary),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.inter(
        color: AppColors.darkText,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.inter(
        color: AppColors.darkTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(color: AppColors.darkText),
      bodyMedium: GoogleFonts.inter(color: AppColors.darkText),
      bodySmall: GoogleFonts.inter(color: AppColors.darkTextSecondary),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.darkText,
      onError: AppColors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.darkText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
    ),

    iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.darkTextSecondary),
    ),
  );
}
