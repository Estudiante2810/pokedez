import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF00D9FF);      // Cyan neón
  static const Color secondaryColor = Color(0xFFFF0080);    // Magenta
  static const Color tertiaryColor = Color(0xFFFF6B35);     // Naranja
  static const Color surfaceColor = Color(0xFF0A0E27);      // Azul oscuro
  static const Color containerColor = Color(0xFF1E2749);    // Azul secundario

  // Tema de la app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
        primaryContainer: containerColor,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      chipTheme: _buildChipTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      floatingActionButtonTheme: _buildFabTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }

  // Tipografía
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.limelight(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      ),
      displayMedium: GoogleFonts.limelight(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      ),
      headlineMedium: GoogleFonts.limelight(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
      ),
      headlineSmall: GoogleFonts.limelight(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
      ),
      titleLarge: GoogleFonts.limelight(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
    );
  }

  // AppBar
  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      titleTextStyle: GoogleFonts.limelight(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        letterSpacing: 2.0,
      ),
    );
  }

  // Cards
  static CardThemeData _buildCardTheme() {
    return const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  // Chips
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: containerColor,
      labelStyle: const TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // Botones Elevated
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: surfaceColor,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Floating Action Button
  static FloatingActionButtonThemeData _buildFabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
    );
  }

  // Input Decoration
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
    );
  }
}