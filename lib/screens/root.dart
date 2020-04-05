import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import './home.dart';
import './loading.dart';
import './welcome.dart';
import './group.dart';
import '../providers/auth.dart';
import '../providers/groups.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  Future<void> _restoreTokens;
  Future<void> _fetchGroups;

  @override
  void initState() {
    super.initState();
    _restoreTokens = Provider.of<Auth>(context, listen: false).restoreTokens();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAuthenticated = Provider.of<Auth>(context).isAuthenticated;
    if (isAuthenticated && _fetchGroups == null) {
      _fetchGroups =
          Provider.of<GroupsProvider>(context, listen: false).fetchGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Auth, bool>(
      selector: (_, auth) => auth.isAuthenticated,
      builder: (_, isAuthenticated, __) => isAuthenticated
          ? Selector<GroupsProvider, Tuple2<bool, bool>>(
              selector: (_, groups) =>
                  Tuple2(groups.needsSync, groups.groups.isEmpty),
              builder: (_, data, __) => data.item1
                  ? FutureBuilder(
                      // FIXME: Gets triggered multiple times on registration / newGroup creation
                      future: _fetchGroups,
                      builder: (_, snapshot) {
                        return snapshot.connectionState ==
                                ConnectionState.waiting
                            ? LoadingScreen()
                            : data.item2 ? GroupScreen() : HomeScreen();
                      })
                  : data.item2 ? GroupScreen() : HomeScreen(),
            )
          : FutureBuilder(
              future: _restoreTokens,
              builder: (_, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? LoadingScreen()
                      : WelcomeScreen(),
            ),
    );
  }
}
