import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './home.dart';
import './loading.dart';
import './welcome.dart';
import './group.dart';
import '../providers/auth.dart';
import '../providers/groups.dart';

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupsState = Provider.of<GroupsProvider>(context);
    return Consumer<Auth>(
      builder: (_, auth, __) => auth.isAuthenticated
          ? groupsState.needsSync
              ? FutureBuilder(
                  // FIXME: Gets triggered multiple times
                  future: groupsState.fetchGroups(),
                  builder: (_, snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? LoadingScreen()
                        : groupsState.groups.isEmpty
                            ? GroupScreen()
                            : HomeScreen();
                  })
              : groupsState.groups.isEmpty ? GroupScreen() : HomeScreen()
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
