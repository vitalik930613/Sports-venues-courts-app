import 'package:flutter/material.dart';
import 'package:cancha_mobile/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeUtils {
  static const _defaultLogo = 'assets/images/cancha_logo.png';
  static const _darkLogo = 'assets/images/cancha_dark_logo.png';

  static const _darkThemes = {'midnight', 'campo', 'arena', 'sunset'};

  static String getLogoPath(BuildContext context) {
    final themeId = Provider.of<ThemeProvider>(context).currentThemeId;
    return _darkThemes.contains(themeId) ? _darkLogo : _defaultLogo;
  }
}
