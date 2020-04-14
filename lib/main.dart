import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry/sentry.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
import './widgets/no_animation_material_page_route.dart';

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

  Route _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Root.routeName:
        return Theme.of(context).platform == TargetPlatform.iOS
            ? CupertinoPageRoute(
                builder: (context) => new Root(),
                settings: settings.copyWith(isInitialRoute: true),
              )
            : NoAnimationMaterialPageRoute(
                builder: (context) => new Root(),
                settings: settings.copyWith(isInitialRoute: true),
              );
      case RegisterScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => RegisterScreen(),
          settings: settings,
        );
      case LoginScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => LoginScreen(),
          settings: settings,
        );
      case ForgotPasswordScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => ForgotPasswordScreen(),
          settings: settings,
        );
      case GroupScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => GroupScreen(arguments: settings.arguments),
          settings: settings,
        );
      case SettingsScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => SettingsScreen(),
          settings: settings,
        );
      case EditNameScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => EditNameScreen(),
          settings: settings,
        );
      case EditEmailScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => EditEmailScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => PlatformApp(
          title: 'Sliceit',
          initialRoute: Root.routeName,
          android: (_) => MaterialAppData(
            theme: theme.currentTheme,
          ),
          onGenerateRoute: _generateRoute,
        ),
      ),
    );
  }
}
