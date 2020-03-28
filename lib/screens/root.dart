import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './overview.dart';
import './loading.dart';
import './welcome.dart';
import '../providers/auth.dart';

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (_, auth, __) => auth.isAuthenticated
          ? OverviewScreen()
          : FutureBuilder(
              future: auth.restoreTokens(),
              builder: (_, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? LoadingScreen()
                      : WelcomeScreen(),
            ),
    );
  }
}
