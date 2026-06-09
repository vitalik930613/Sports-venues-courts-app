import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

const _kThemeKey = 'app_theme_id';

class ThemeProvider extends ChangeNotifier {
  String _currentThemeId = AppThemes.defaultId;

  ThemeProvider() {
    _loadSavedTheme();
  }

  String get currentThemeId => _currentThemeId;

  ThemeData get currentTheme => AppThemes.getTheme(_currentThemeId);

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved != null) {
      _currentThemeId = saved;
      notifyListeners();
    }
  }

  Future<void> setTheme(String themeId) async {
    if (_currentThemeId == themeId) return;
    _currentThemeId = themeId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, themeId);
  }
}
