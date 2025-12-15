import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color neuralBlack = Color(0xFF0A0E17); // Deepest background
  static const Color neuralDark = Color(0xFF131625); // Card background
  static const Color neuralBlue = Color(0xFF4C6EF5); // Primary accent
  static const Color neuralPurple = Color(0xFF9D4EDD); // Secondary accent
  static const Color neuralGreen = Color(0xFF00B894); // Success
  static const Color neuralRed = Color(0xFFFF7675); // Error
  static const Color neuralOrange = Color(0xFFFFA500); // Warning/Action

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB2BEC3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neuralBlue, neuralPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1FFFFFFF), // White with very low opacity
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neuralBlack,
      primaryColor: neuralBlue,
      
      // Text Theme
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textWhite,
        displayColor: textWhite,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w600, 
          color: textWhite
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neuralBlue,
          foregroundColor: textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: neuralDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neuralDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neuralBlue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        labelStyle: const TextStyle(color: textGrey),
        hintStyle: TextStyle(color: textGrey.withOpacity(0.6)),
      ),
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: neuralBlue,
        secondary: neuralPurple,
        surface: neuralDark,
        error: neuralRed,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onSurface: textWhite,
        onError: neuralBlack,
      ),
    );
  }
}
