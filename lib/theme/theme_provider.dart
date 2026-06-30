import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

const _kThemeKeyPrefix = 'app_theme_id';

class ThemeProvider extends ChangeNotifier {
  String _currentThemeId = AppThemes.defaultId;
  int? _currentUserId;
  bool _currentUserIsPremium = false;

  ThemeProvider();

  String get currentThemeId => _currentThemeId;

  ThemeData get currentTheme => AppThemes.getTheme(_currentThemeId);

  Future<void> syncThemeForUser({
    required int userId,
    required bool isPremium,
  }) async {
    _currentUserId = userId;
    _currentUserIsPremium = isPremium;

    final prefs = await SharedPreferences.getInstance();
    final key = _themeKeyForUser(userId);
    final savedThemeId = prefs.getString(key);
    final nextThemeId = _allowedThemeOrDefault(savedThemeId, isPremium);

    if (savedThemeId != nextThemeId) {
      await prefs.setString(key, nextThemeId);
    }

    _applyTheme(nextThemeId);
  }

  Future<bool> setTheme(
    String themeId, {
    required int userId,
    required bool isPremium,
  }) async {
    if (!AppThemes.isKnownTheme(themeId)) return false;
    if (AppThemes.isPremiumTheme(themeId) && !isPremium) return false;

    _currentUserId = userId;
    _currentUserIsPremium = isPremium;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKeyForUser(userId), themeId);
    _applyTheme(themeId);
    return true;
  }

  Future<void> resetToDefault({int? userId}) async {
    final targetUserId = userId ?? _currentUserId;
    _currentUserId = targetUserId;
    _currentUserIsPremium = false;

    if (targetUserId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKeyForUser(targetUserId), AppThemes.defaultId);
    }

    _applyTheme(AppThemes.defaultId);
  }

  void resetToGuestDefault() {
    _currentUserId = null;
    _currentUserIsPremium = false;
    _applyTheme(AppThemes.defaultId);
  }

  String _allowedThemeOrDefault(String? themeId, bool isPremium) {
    if (themeId == null || !AppThemes.isKnownTheme(themeId)) {
      return AppThemes.defaultId;
    }

    if (AppThemes.isPremiumTheme(themeId) && !isPremium) {
      return AppThemes.defaultId;
    }

    return themeId;
  }

  String _themeKeyForUser(int userId) {
    return '${_kThemeKeyPrefix}_$userId';
  }

  void _applyTheme(String themeId) {
    final nextThemeId = _allowedThemeOrDefault(
      themeId,
      _currentUserIsPremium,
    );

    if (_currentThemeId == nextThemeId) return;
    _currentThemeId = nextThemeId;
    notifyListeners();
  }
}
