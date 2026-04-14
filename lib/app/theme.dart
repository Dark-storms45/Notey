// lib/app/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// NOtey Design Tokens
/// ---------------------------------------------------------------------------
class NOteyColors {
  NOteyColors._();

  // Brand
  static const primary = Color(0xFFE040C8);       // magenta-pink
  static const primaryDark = Color(0xFFB52DA3);
  static const primaryLight = Color(0xFFF06BE0);

  // Semantic / card palette (user-chosen at runtime; these are defaults)
  static const cardPurple = Color(0xFF5B3FA0);
  static const cardGreen = Color(0xFF4D6B1A);
  static const cardRed = Color(0xFFD44B3B);
  static const cardAmber = Color(0xFFB87A1A);
  static const cardBlue = Color(0xFF2B5BAD);
  static const cardBlack = Color(0xFF1A1A1A);
  static const cardBrightGreen = Color(0xFF2D8C4E);

  // Recording screen
  static const recordingBlue = Color(0xFF1C4DBF);
  static const recordingRed = Color(0xFFD43B2B);

  // Neutral
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF5F5F7);
  static const surface = Color(0xFFEEEEEE);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const scaffoldDark = Color(0xFF0A0A0A);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF555555);
  static const textHint = Color(0xFF999999);
  static const divider = Color(0xFFDDDDDD);
}

/// ---------------------------------------------------------------------------
/// NOtey Theme
/// ---------------------------------------------------------------------------
abstract class NOteyTheme {
  NOteyTheme._();

  // ── Text Themes ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color bodyColor, Color headlineColor) {
    return TextTheme(
      // Headlines / Titles – Syne
      displayLarge: GoogleFonts.syne(
        fontSize: 32, fontWeight: FontWeight.w800, color: headlineColor,
      ),
      displayMedium: GoogleFonts.syne(
        fontSize: 26, fontWeight: FontWeight.w700, color: headlineColor,
      ),
      displaySmall: GoogleFonts.syne(
        fontSize: 22, fontWeight: FontWeight.w700, color: headlineColor,
      ),
      headlineLarge: GoogleFonts.syne(
        fontSize: 20, fontWeight: FontWeight.w700, color: headlineColor,
      ),
      headlineMedium: GoogleFonts.syne(
        fontSize: 18, fontWeight: FontWeight.w600, color: headlineColor,
      ),
      headlineSmall: GoogleFonts.syne(
        fontSize: 16, fontWeight: FontWeight.w600, color: headlineColor,
      ),
      titleLarge: GoogleFonts.syne(
        fontSize: 16, fontWeight: FontWeight.w700, color: headlineColor,
      ),
      titleMedium: GoogleFonts.syne(
        fontSize: 14, fontWeight: FontWeight.w600, color: headlineColor,
      ),
      titleSmall: GoogleFonts.syne(
        fontSize: 12, fontWeight: FontWeight.w600, color: headlineColor,
      ),
      // Body / Captions – DM Sans
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: bodyColor,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: bodyColor,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: bodyColor,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: bodyColor,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: bodyColor,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 10, fontWeight: FontWeight.w500, color: bodyColor,
        letterSpacing: 0.4,
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: NOteyColors.primary,
      onPrimary: NOteyColors.white,
      secondary: NOteyColors.primaryLight,
      onSecondary: NOteyColors.white,
      surface: NOteyColors.white,
      onSurface: NOteyColors.textPrimary,
      surfaceContainerHighest: NOteyColors.surface,
      outline: NOteyColors.divider,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NOteyColors.white,
      textTheme: _buildTextTheme(NOteyColors.textPrimary, NOteyColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: NOteyColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: NOteyColors.textPrimary),
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: NOteyColors.textPrimary,
        ),
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NOteyColors.white,
        selectedItemColor: NOteyColors.primary,
        unselectedItemColor: NOteyColors.textHint,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NOteyColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NOteyColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: NOteyColors.textHint, fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NOteyColors.primary,
          foregroundColor: NOteyColors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: NOteyColors.surface,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NOteyColors.surface,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: NOteyColors.divider, thickness: 0.5,
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: NOteyColors.primaryLight,
      onPrimary: NOteyColors.white,
      secondary: NOteyColors.primary,
      onSecondary: NOteyColors.white,
      surface: NOteyColors.surfaceDark,
      onSurface: Color(0xFFF0F0F0),
      surfaceContainerHighest: Color(0xFF2A2A2A),
      outline: Color(0xFF3A3A3A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NOteyColors.scaffoldDark,
      textTheme: _buildTextTheme(const Color(0xFFF0F0F0), const Color(0xFFF0F0F0)),
      appBarTheme: AppBarTheme(
        backgroundColor: NOteyColors.scaffoldDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF0F0F0)),
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF0F0F0),
        ),
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NOteyColors.surfaceDark,
        selectedItemColor: NOteyColors.primaryLight,
        unselectedItemColor: const Color(0xFF666666),
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NOteyColors.primaryLight, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: const Color(0xFF666666), fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NOteyColors.primary,
          foregroundColor: NOteyColors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: const Color(0xFF2A2A2A),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2A2A2A),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFF0F0F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A), thickness: 0.5,
      ),
    );
  }
}