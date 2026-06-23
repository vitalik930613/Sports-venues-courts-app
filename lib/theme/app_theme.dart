import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static const String defaultId = 'default';
  static const String midnightId = 'midnight';
  static const String campoId = 'campo';
  static const String arenaId = 'arena';
  static const String sunsetId = 'sunset';

  // Função getTheme – deve existir
  static ThemeData getTheme(String themeId) {
    switch (themeId) {
      case midnightId:
        return _midnight;
      case campoId:
        return _campo;
      case arenaId:
        return _arena;
      case sunsetId:
        return _sunset;
      case defaultId:
      default:
        return _default;
    }
  }

  // Função _build – deve existir
  static ThemeData _build({
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color surface,
    required Color background,
    required Color onBackground,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onPrimary,
      error: Colors.red.shade700,
      onError: Colors.white,
      surface: surface,
      onSurface: brightness == Brightness.dark ? Colors.white : Colors.black,
      background: background,
      onBackground: onBackground,
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      brightness: brightness,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark ? surface : Colors.white,
        foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        prefixIconColor: primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: brightness == Brightness.dark ? surface : Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? primary : null,
        ),
      ),
    );
  }

  static final ThemeData _default = _build(
    primary: const Color(0xFF2E7D32),
    onPrimary: Colors.white,
    secondary: const Color(0xFF81C784),
    surface: Colors.white,
    background: Colors.grey.shade50,
    onBackground: Colors.black87,
    brightness: Brightness.light,
  );

  static final ThemeData _midnight = _build(
    primary: const Color(0xFFFF6B6B),
    onPrimary: Colors.white,
    secondary: const Color(0xFF4ECDC4),
    surface: const Color(0xFF1A1A2E),
    background: const Color(0xFF16213E),
    onBackground: Colors.white70,
    brightness: Brightness.dark,
  );

  static final ThemeData _campo = _build(
    primary: const Color(0xFF4CAF50),
    onPrimary: Colors.white,
    secondary: const Color(0xFFFFC107),
    surface: const Color(0xFF1B5E20),
    background: const Color(0xFF1B5E20),
    onBackground: Colors.white70,
    brightness: Brightness.dark,
  );

  static final ThemeData _arena = _build(
    primary: const Color(0xFF2979FF),
    onPrimary: Colors.white,
    secondary: const Color(0xFF82B1FF),
    surface: const Color(0xFF0D47A1),
    background: const Color(0xFF0D47A1),
    onBackground: Colors.white70,
    brightness: Brightness.dark,
  );

  static final ThemeData _sunset = _build(
    primary: const Color(0xFFFF6F00),
    onPrimary: Colors.white,
    secondary: const Color(0xFFFFD54F),
    surface: const Color(0xFFBF360C),
    background: const Color(0xFFBF360C),
    onBackground: Colors.white70,
    brightness: Brightness.dark,
  );
}