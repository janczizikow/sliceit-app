import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType {
  light,
  dark,
}

class ThemeProvider with ChangeNotifier {
  static const THEME_PREFERENCE_KEY = 'THEME_PREFERENCE_KEY';
  static final ThemeData _darkTheme = ThemeData.dark();
  static final ThemeData _lightTheme = ThemeData.light();
  final SharedPreferences prefs;
  ThemeType _themeType = ThemeType.light;
  ThemeData currentTheme = _lightTheme;

  ThemeProvider(this.prefs);

  bool get isDark {
    return _themeType == ThemeType.dark;
  }

  bool get isLight {
    return _themeType == ThemeType.light;
  }

  void toggleTheme() {
    if (_themeType == ThemeType.light) {
      _themeType = ThemeType.dark;
      currentTheme = _darkTheme;
    } else {
      _themeType = ThemeType.light;
      currentTheme = _lightTheme;
    }
    notifyListeners();
    _storePreferredTheme(_themeType);
  }

  Future<void> loadPreferredTheme() async {
    int themeTypeIndex = prefs.getInt(THEME_PREFERENCE_KEY) ?? 0;
    ThemeType themeType = ThemeType.values.elementAt(themeTypeIndex);
    if (themeType == ThemeType.light) {
      currentTheme = _lightTheme;
    } else {
      currentTheme = _darkTheme;
    }
    _themeType = themeType;
    notifyListeners();
  }

  Future<void> _storePreferredTheme(ThemeType themeType) async {
    prefs.setInt(THEME_PREFERENCE_KEY, ThemeType.values.indexOf(themeType));
  }
}
