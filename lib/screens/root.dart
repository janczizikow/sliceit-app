import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/screens/offline.dart';
import 'package:tuple/tuple.dart';

import './home.dart';
import './loading.dart';
import './welcome.dart';
import './group.dart';
import '../providers/base.dart';
import '../providers/auth.dart';
import '../providers/groups.dart';

class Root extends StatefulWidget {
  const Root({
    Key key,
  }) : super(key: key);

  static const routeName = '/';

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  Future<void> _restoreTokens;

  @override
  void initState() {
    super.initState();
    _restoreTokens = Provider.of<Auth>(context, listen: false).restoreTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<Auth, GroupsProvider, Tuple3<bool, Status, bool>>(
      selector: (_, auth, groups) =>
          Tuple3(auth.isAuthenticated, groups.status, groups.hasGroups),
      builder: (_, data, __) => data.item1
          ? data.item2 == Status.REJECTED
              ? OfflineScreen()
              : data.item2 == Status.PENDING
                  ? LoadingScreen()
                  : data.item3 ? HomeScreen() : GroupScreen()
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
