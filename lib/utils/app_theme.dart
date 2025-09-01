import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales inspirados en Elden Ring
  static const Color primaryColor = Color(0xFFF59E0B); // Ámbar dorado
  static const Color secondaryColor = Color(0xFF1F2937); // Gris oscuro
  static const Color backgroundColor = Color(0xFF111827); // Negro azulado
  static const Color surfaceColor = Color(0xFF374151); // Gris medio
  static const Color textColor = Color(0xFFF9FAFB); // Blanco
  static const Color textSecondaryColor = Color(0xFF9CA3AF); // Gris claro
  
  // Colores para dificultad
  static const Color easyColor = Color(0xFF10B981); // Verde
  static const Color mediumColor = Color(0xFFF59E0B); // Amarillo
  static const Color hardColor = Color(0xFFF97316); // Naranja
  static const Color veryHardColor = Color(0xFFEF4444); // Rojo

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.black,
        onSecondary: textColor,
        onSurface: textColor,
        onBackground: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryColor,
          fontSize: 14,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceColor,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return surfaceColor.withOpacity(0.3);
        }),
        checkColor: MaterialStateProperty.all(Colors.black),
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // Método para obtener el color de dificultad
  static Color getDifficultyColor(int difficulty) {
    if (difficulty <= 2) return easyColor;
    if (difficulty <= 4) return mediumColor;
    if (difficulty <= 6) return hardColor;
    return veryHardColor;
  }

  // Método para obtener el texto de dificultad
  static String getDifficultyText(int difficulty) {
    if (difficulty <= 2) return 'Fácil';
    if (difficulty <= 4) return 'Medio';
    if (difficulty <= 6) return 'Difícil';
    return 'Muy Difícil';
  }
}
