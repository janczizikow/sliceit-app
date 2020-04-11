import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry/sentry.dart';

import './providers/auth.dart';
import './providers/account.dart';
import './providers/theme.dart';
import './providers/groups.dart';
import './screens/root.dart';
import './screens/login.dart';
import './screens/forgot_password.dart';
import './screens/register.dart';
import './screens/group.dart';
import './screens/settings.dart';
import './screens/edit_name.dart';
import './screens/edit_email.dart';

Future<Null> main() async {
  await DotEnv().load('.env');
  final SentryClient _sentry =
      new SentryClient(dsn: DotEnv().env['SENTRY_DNS']);
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (!kReleaseMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  // This creates a [Zone] that contains the Flutter application and stablishes
  // an error handler that captures errors and reports them.
  // https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
  runZoned<Future<Null>>(() async {
    runApp(new MyApp());
  }, onError: (error, stackTrace) async {
    if (!kReleaseMode) {
      print(stackTrace);
      print('In dev mode. Not sending report to Sentry.io.');
    } else {
      await _sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  });
}

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
      GroupScreen.routeName: (context) =>
          GroupScreen(arguments: ModalRoute.of(context).settings.arguments),
      SettingsScreen.routeName: (context) => SettingsScreen(),
      EditNameScreen.routeName: (context) => EditNameScreen(),
      EditEmailScreen.routeName: (context) => EditEmailScreen(),
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => themeProvider,
        ),
        ChangeNotifierProvider(create: (_) => GroupsProvider())
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
