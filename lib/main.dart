import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliceit/providers/account.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/providers/expenses.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/providers/invites.dart';
import 'package:sliceit/providers/theme.dart';
import 'package:sliceit/screens/edit_email.dart';
import 'package:sliceit/screens/edit_group.dart';
import 'package:sliceit/screens/edit_name.dart';
import 'package:sliceit/screens/forgot_password.dart';
import 'package:sliceit/screens/group_invites.dart';
import 'package:sliceit/screens/login.dart';
import 'package:sliceit/screens/new_expense.dart';
import 'package:sliceit/screens/new_payment.dart';
import 'package:sliceit/screens/register.dart';
import 'package:sliceit/screens/root.dart';
import 'package:sliceit/screens/settings.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/services/navigation_service.dart';
import 'package:sliceit/widgets/no_animation_material_page_route.dart';
import 'package:tuple/tuple.dart';

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

  // This creates a [Zone] that contains the Flutter application and establishes
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
  static final NavigationService _navigationService = NavigationService();
  static final Auth _auth = Auth(_navigationService);

  Future<void> _showForceLogoutDialog() async {
    final context =
        _navigationService.navigationKey.currentState.overlay.context;
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    Provider.of<Auth>(context, listen: false).forceLogoutTimestamp = null;
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
      case EditGroupScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => EditGroupScreen(
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
          create: (_) => ThemeProvider(widget.prefs)..loadPreferredTheme(),
        ),
        ChangeNotifierProvider<Auth>(
          create: (_) => _auth..restoreTokens(),
        ),
        Provider<Api>(
          create: (_) => Api(_auth),
        ),
      ],
      child: Consumer<Api>(
        builder: (_, api, __) => MultiProvider(
          providers: [
            ChangeNotifierProxyProvider2<Api, Auth, AccountProvider>(
              create: (_) => AccountProvider(api),
              update: (_, api, auth, account) {
                if (auth.forceLogoutTimestamp != null) {
                  account.reset();
                }
                return account;
              },
            ),
            ChangeNotifierProxyProvider2<Api, Auth, GroupsProvider>(
                create: (_) => GroupsProvider(api),
                update: (_, api, auth, groups) {
                  if (auth.forceLogoutTimestamp != null) {
                    groups.reset();
                  }
                  groups.isAuthenticated =
                      auth.status == AuthStatus.AUTHENTICATED;
                  return groups;
                }),
            ChangeNotifierProxyProvider2<Api, Auth, InvitesProvider>(
              create: (_) => InvitesProvider(api),
              update: (_, api, auth, invites) {
                if (auth.forceLogoutTimestamp != null) {
                  invites.reset();
                }
                return invites;
              },
            ),
            ChangeNotifierProvider(
              create: (_) => ExpensesProvider(api),
            ),
          ],
          child: Selector2<ThemeProvider, Auth, Tuple2<ThemeData, int>>(
            selector: (
              ___,
              theme,
              auth,
            ) =>
                Tuple2(theme.currentTheme, auth.forceLogoutTimestamp),
            builder: (_, data, __) {
              if (data.item2 != null) {
                _showForceLogoutDialog();
              }
              return PlatformApp(
                title: 'Sliceit',
                initialRoute: Root.routeName,
                navigatorKey: _navigationService.navigationKey,
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
        ),
      ),
    );
  }
}
