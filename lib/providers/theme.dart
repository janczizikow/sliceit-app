import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType {
  light,
  dark,
}

class ThemeProvider with ChangeNotifier {
  static const THEME_PREFERENCE_KEY = 'THEME_PREFERENCE_KEY';
  static final ThemeData _darkTheme = ThemeData.dark().copyWith(
    errorColor: const Color(0xffff4b58),
    textTheme: ThemeData.dark().textTheme.copyWith(
          button: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          headline6: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
    buttonTheme: ThemeData.dark().buttonTheme.copyWith(
          textTheme: ButtonTextTheme.primary,
          height: 38.0,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
        ),
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          textTheme: ThemeData.dark().primaryTextTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
        ),
  );

  static const primarySwatch = MaterialColor(0xff0069ff, <int, Color>{
    50: Color(0xffe0edff),
    100: Color(0xffb3d2ff),
    200: Color(0xff80b4ff),
    300: Color(0xff4d96ff),
    400: Color(0xff2680ff),
    500: Color(0xff0069ff),
    600: Color(0xff0061ff),
    700: Color(0xff0056ff),
    800: Color(0xff004cff),
    900: Color(0xff3bff),
  });

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: primarySwatch,
    errorColor: const Color(0xffff4b58),
    backgroundColor: const Color(0xff0069ff),
    scaffoldBackgroundColor: const Color(0xfffafafb),
    textTheme: ThemeData.light().textTheme.copyWith(
          button: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          headline6: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
          textTheme: ThemeData.light().primaryTextTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
        ),
    buttonColor: const Color(0xff0069ff),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(0xff0069ff),
      textTheme: ButtonTextTheme.primary,
      height: 38.0,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
    ),
  );
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
