import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static const String defaultId = 'default';
  static const String midnightId = 'midnight';
  static const String campoId = 'campo';
  static const String arenaId = 'arena';
  static const String sunsetId = 'sunset';

  static const Set<String> premiumThemeIds = {
    midnightId,
    campoId,
    arenaId,
    sunsetId,
  };

  static const Set<String> knownThemeIds = {
    defaultId,
    midnightId,
    campoId,
    arenaId,
    sunsetId,
  };

  static bool isPremiumTheme(String themeId) {
    return premiumThemeIds.contains(themeId);
  }

  static bool isKnownTheme(String themeId) {
    return knownThemeIds.contains(themeId);
  }

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

  static ThemeData _build({
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color surface,
    required Color background,
    required Color onBackground,
    required Brightness brightness,
  }) {
    final onSurface = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final appBarBackground = brightness == Brightness.dark
        ? surface
        : Colors.white;
    final bottomNavBackground = brightness == Brightness.dark
        ? surface
        : Colors.white;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: Colors.red.shade700,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      brightness: brightness,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
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
        labelStyle: TextStyle(color: onSurface),
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: onSurface.withValues(alpha: 0.72),
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(
          color: onSurface.withValues(alpha: 0.72),
        ),
        selectedLabelStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          color: onSurface.withValues(alpha: 0.72),
        ),
        backgroundColor: bottomNavBackground,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : null,
        ),
      ),
    );
  }

  static final ThemeData _default = _build(
    primary: const Color(0xFF2E7D32),
    onPrimary: Colors.white,
    secondary: const Color(0xFF81C784),
    onSecondary: Colors.black,
    surface: Colors.white,
    background: Colors.grey.shade50,
    onBackground: Colors.black87,
    brightness: Brightness.light,
  );

  static final ThemeData _midnight = _build(
    primary: const Color(0xFFFF8A80),
    onPrimary: Colors.black,
    secondary: const Color(0xFF4ECDC4),
    onSecondary: Colors.black,
    surface: const Color(0xFF1A1A2E),
    background: const Color(0xFF16213E),
    onBackground: Colors.white70,
    brightness: Brightness.dark,
  );

  static final ThemeData _campo = _build(
    primary: const Color(0xFF66BB6A),
    onPrimary: Colors.black,
    secondary: const Color(0xFFFFC107),
    onSecondary: Colors.black,
    surface: const Color(0xFF245A2A),
    background: const Color(0xFF17461B),
    onBackground: Colors.white,
    brightness: Brightness.dark,
  );

  static final ThemeData _arena = _build(
    primary: const Color(0xFF82B1FF),
    onPrimary: Colors.black,
    secondary: const Color(0xFF40C4FF),
    onSecondary: Colors.black,
    surface: const Color(0xFF153C86),
    background: const Color(0xFF0B2F6B),
    onBackground: Colors.white,
    brightness: Brightness.dark,
  );

  static final ThemeData _sunset = _build(
    primary: const Color(0xFFFFB74D),
    onPrimary: Colors.black,
    secondary: const Color(0xFFFFD54F),
    onSecondary: Colors.black,
    surface: const Color(0xFF8E2E10),
    background: const Color(0xFF5E250D),
    onBackground: Colors.white,
    brightness: Brightness.dark,
  );
}
