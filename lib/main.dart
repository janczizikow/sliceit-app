import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliceit/providers/invites.dart';
import 'package:tuple/tuple.dart';

import './services/api.dart';
import './providers/account.dart';
import './providers/auth.dart';
import './providers/groups.dart';
import './providers/theme.dart';
import './providers/expenses.dart';
import './screens/root.dart';
import './screens/forgot_password.dart';
import './screens/group.dart';
import './screens/group_invites.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/settings.dart';
import './screens/edit_email.dart';
import './screens/edit_name.dart';
import './screens/new_payment.dart';
import './screens/new_expense.dart';
import './widgets/no_animation_material_page_route.dart';

Future<Null> main() async {
  await DotEnv().load('.env');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
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
    runApp(new MyApp(prefs));
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
  final SharedPreferences prefs;
  MyApp(this.prefs);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = ThemeProvider(widget.prefs);
    _loadPreferredTheme();
  }

  Future<void> _loadPreferredTheme() async {
    ThemeType preferredTheme = await themeProvider.loadPreferredTheme();
    themeProvider.themeType = preferredTheme;
  }

  Future<void> _showForceLogoutDialog() async {
    final context = navigatorKey.currentState.overlay.context;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    Provider.of<Api>(context, listen: false).setForceLogoutTimestamp(null);
    await showPlatformDialog(
        context: context,
        androidBarrierDismissible: false,
        builder: (_) {
          return PlatformAlertDialog(
            title: const Text('Unauthorized'),
            content: const Text('Session expired, you will be logged out now'),
            actions: <Widget>[
              PlatformDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
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
          builder: (context) => GroupScreen(
            arguments: settings.arguments,
          ),
          settings: settings,
        );
      case GroupInvitesScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => GroupInvitesScreen(
            groupId: settings.arguments,
          ),
          fullscreenDialog: true,
          settings: settings,
        );
      case NewPaymentScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => NewPaymentScreen(),
          fullscreenDialog: true,
        );
      case NewExpenseScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => NewExpenseScreen(),
          fullscreenDialog: true,
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
          create: (_) => Api(),
        ),
        ChangeNotifierProvider(
          create: (_) => themeProvider,
        ),
        ChangeNotifierProxyProvider<Api, Auth>(
          create: (_) => Auth()..restoreTokens(),
          update: (_, api, auth) {
            if (api.forceLogoutTimestamp() != null) {
              auth.logout();
            }
            return auth;
          },
        ),
        ChangeNotifierProxyProvider<Api, AccountProvider>(
          create: (_) => AccountProvider(),
          update: (_, api, account) {
            if (api.forceLogoutTimestamp() != null) {
              account.reset();
            }
            return account;
          },
        ),
        ChangeNotifierProxyProvider2<Auth, Api, GroupsProvider>(
            create: (_) => GroupsProvider(),
            update: (_, auth, api, groups) {
              if (api.forceLogoutTimestamp() != null) {
                groups.reset();
              }
              groups.isAuthenticated = auth.isAuthenticated;
              return groups;
            }),
        ChangeNotifierProxyProvider<Api, InvitesProvider>(
          create: (_) => InvitesProvider(),
          update: (_, api, invites) {
            if (api.forceLogoutTimestamp() != null) {
              invites.reset();
            }
            return invites;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ExpensesProvider(),
        ),
      ],
      child: Selector2<ThemeProvider, Api, Tuple2<ThemeData, int>>(
        selector: (
          _,
          theme,
          api,
        ) =>
            Tuple2(theme.currentTheme, api.forceLogoutTimestamp()),
        builder: (_, data, __) {
          if (data.item2 != null) {
            _showForceLogoutDialog();
          }
          return PlatformApp(
            title: 'Sliceit',
            initialRoute: Root.routeName,
            navigatorKey: navigatorKey,
            ios: (_) => CupertinoAppData(
              theme: CupertinoThemeData(
                brightness: data.item1.brightness,
              ),
            ),
            android: (_) => MaterialAppData(
              theme: data.item1,
            ),
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }
}
