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
  ThemeType _themeType = ThemeType.light;
  ThemeData currentTheme = _lightTheme;
  ThemeProvider();

  bool get isDark {
    return _themeType == ThemeType.dark;
  }

  bool get isLight {
    return _themeType == ThemeType.light;
  }

  set themeType(ThemeType themeType) {
    if (themeType == ThemeType.light) {
      currentTheme = _lightTheme;
    } else {
      currentTheme = _darkTheme;
    }
    _themeType = themeType;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeType == ThemeType.light) {
      _themeType = ThemeType.dark;
      currentTheme = _darkTheme;
    } else {
      _themeType = ThemeType.light;
      currentTheme = _lightTheme;
    }
    _storePreferredTheme(_themeType);
    notifyListeners();
  }

  Future<ThemeType> loadPreferredTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int themeTypeIndex = prefs.getInt(THEME_PREFERENCE_KEY) ?? 0;
    return ThemeType.values.elementAt(themeTypeIndex);
  }

  Future<void> _storePreferredTheme(ThemeType themeType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(THEME_PREFERENCE_KEY, ThemeType.values.indexOf(themeType));
  }
}
