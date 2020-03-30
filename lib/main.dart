import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/theme.dart';
import './screens/root.dart';
import './screens/login.dart';
import './screens/forgot_password.dart';
import './screens/register.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeProvider themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _loadPreferredTheme();
  }

  Future<void> _loadPreferredTheme() async {
    ThemeType preferredTheme = await themeProvider.loadPreferredTheme();
    themeProvider.themeType = preferredTheme;
  }

  @override
  Widget build(BuildContext context) {
    final routes = {
      LoginScreen.routeName: (context) => LoginScreen(),
      ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
      RegisterScreen.routeName: (context) => RegisterScreen(),
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => themeProvider,
        ),
      ],
      child: Theme.of(context).platform == TargetPlatform.iOS
          ? CupertinoApp(
              title: 'Sliceit',
              home: Root(),
              routes: routes,
            )
          : Consumer<ThemeProvider>(
              builder: (_, theme, __) => MaterialApp(
                title: 'Sliceit',
                home: Root(),
                routes: routes,
                theme: theme.currentTheme,
              ),
            ),
    );
  }
}
