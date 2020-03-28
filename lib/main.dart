import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/root.dart';
import './screens/login.dart';
import './screens/register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routes = {
      LoginScreen.routeName: (context) => LoginScreen(),
      RegisterScreen.routeName: (context) => RegisterScreen(),
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
      ],
      child: Theme.of(context).platform == TargetPlatform.iOS
          ? CupertinoApp(
              title: 'Sliceit',
              home: Root(),
              routes: routes,
            )
          : MaterialApp(
              title: 'Sliceit',
              home: Root(),
              routes: routes,
            ),
    );
  }
}
