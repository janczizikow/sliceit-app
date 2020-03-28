import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/loading.dart';
import './screens/welcome.dart';
import './screens/overview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<Auth>(
          builder: (_, auth, __) => auth.isAuthenticated
              ? OverviewScreen()
              : FutureBuilder(
                  future: auth.restoreTokens(),
                  builder: (_, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? LoadingScreen()
                          : WelcomeScreen(),
                ),
        ),
        routes: {},
      ),
    );
  }
}
