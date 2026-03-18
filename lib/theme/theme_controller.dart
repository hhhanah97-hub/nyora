import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeIndexKey = "selected_theme_index";

  AppTheme _currentTheme = AppTheme.customLight;
  AppTheme get currentTheme => _currentTheme;

  ThemeController() {
    _loadFromPrefs();
  }

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    _saveToPrefs();
    notifyListeners();
  }

  // Uložíme si, kolikáté téma v seznamu je vybrané
  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    int index = AppTheme.allThemes.indexOf(_currentTheme);
    if (index != -1) await prefs.setInt(_themeIndexKey, index);
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeIndexKey) ?? 0;
    _currentTheme = AppTheme.allThemes[index];
    notifyListeners();
  }

  ThemeData get themeData {
    // Nejdříve zjistíme, jestli je pozadí světlé nebo tmavé
    final isDark = _currentTheme.background.computeLuminance() < 0.5;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true, // Doporučuji pro lepší barvy
      brightness: brightness,
      scaffoldBackgroundColor: _currentTheme.background,
      primaryColor: _currentTheme.accent,
      cardColor: _currentTheme.card,

      // Tady je ta důležitá oprava: brightness musí být stejná v ThemeData i ColorScheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _currentTheme.accent,
        brightness: brightness, // Tady jsme to sjednotili
        surface: _currentTheme.background,
      ),

      // Barvy pro AppBar, aby ladily
      appBarTheme: AppBarTheme(
        backgroundColor: _currentTheme.background,
        foregroundColor: _currentTheme.textOnBackground,
        elevation: 0,
      ),
    );
  }
}
