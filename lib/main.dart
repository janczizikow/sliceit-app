import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:sliceit/screens/expense.dart';
import 'package:sliceit/screens/forgot_password.dart';
import 'package:sliceit/screens/group_invites.dart';
import 'package:sliceit/screens/login.dart';
import 'package:sliceit/screens/notifications.dart';
import 'package:sliceit/screens/payment.dart';
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<String> _fcmRegistrationToken = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((String token) {
      _fcmRegistrationToken.value = token ?? '';
    });
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (message.containsKey('notification')) {
          await _showLocalNotification(
            message['notification']['title'],
            message['notification']['body'],
          );
        }
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );
  }

  Future<void> _showLocalNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'foreground',
      'Foreground',
      'Foreground Notifications',
      styleInformation: BigTextStyleInformation(''),
      color: const Color(0xff0062ff),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    // Workaround for
    // https://github.com/FirebaseExtended/flutterfire/issues/1669
    // use the same id to prevent duplicate notifications
    const id = 0;
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

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
                builder: (context) => Root(),
                settings: settings,
              )
            : NoAnimationMaterialPageRoute(
                builder: (context) => Root(),
                settings: settings,
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
      case PaymentScreen.routeName:
        final PaymentScreenArguments args = settings.arguments;
        return platformPageRoute(
          context: context,
          builder: (context) =>
              PaymentScreen(expenseId: args?.expenseId ?? null),
          fullscreenDialog: args?.expenseId == null ?? true,
        );
      case ExpenseScreen.routeName:
        final ExpenseScreenArguments args = settings.arguments;
        return platformPageRoute(
          context: context,
          builder: (context) =>
              ExpenseScreen(expenseId: args?.expenseId ?? null),
          fullscreenDialog: args?.expenseId == null ?? true,
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
      case NotificationsScreen.routeName:
        return platformPageRoute(
          context: context,
          builder: (context) => NotificationsScreen(),
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
        ValueListenableProvider<String>.value(
          value: _fcmRegistrationToken,
        ),
      ],
      child: Consumer2<Api, String>(
        builder: (_, api, fcmRegistrationToken, __) => MultiProvider(
          providers: [
            ChangeNotifierProxyProvider2<Auth, String, AccountProvider>(
              create: (_) => AccountProvider(api),
              update: (_, auth, fcmRegistrationToken, account) {
                account.fcmRegistrationToken = fcmRegistrationToken;
                if (auth.forceLogoutTimestamp != null) {
                  account.reset();
                }
                return account;
              },
            ),
            ChangeNotifierProxyProvider<Auth, GroupsProvider>(
                create: (_) => GroupsProvider(api),
                update: (_, auth, groups) {
                  if (auth.forceLogoutTimestamp != null) {
                    groups.reset();
                  }
                  groups.isAuthenticated =
                      auth.status == AuthStatus.AUTHENTICATED;
                  return groups;
                }),
            ChangeNotifierProxyProvider<Auth, InvitesProvider>(
              create: (_) => InvitesProvider(api),
              update: (_, auth, invites) {
                if (auth.forceLogoutTimestamp != null) {
                  invites.reset();
                }
                return invites;
              },
            ),
            ChangeNotifierProxyProvider2<Auth, GroupsProvider,
                ExpensesProvider>(
              create: (_) => ExpensesProvider(api),
              update: (_, auth, groups, expenses) {
                expenses.groupsProvider = groups;
                if (auth.forceLogoutTimestamp != null) {
                  expenses.reset();
                }
                return expenses;
              },
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
