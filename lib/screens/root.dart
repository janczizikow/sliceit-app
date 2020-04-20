import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/screens/group.dart';
import 'package:sliceit/screens/home.dart';
import 'package:sliceit/screens/loading.dart';
import 'package:sliceit/screens/offline.dart';
import 'package:sliceit/screens/welcome.dart';
import 'package:tuple/tuple.dart';

class Root extends StatelessWidget {
  static const routeName = '/';
  const Root({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector2<Auth, GroupsProvider, Tuple3<AuthStatus, Status, bool>>(
      selector: (_, auth, groups) => Tuple3(
        auth.status,
        groups.status,
        groups.isNotEmpty,
      ),
      builder: (_, data, __) => data.item1 == AuthStatus.AUTHENTICATED
          ? data.item2 == Status.REJECTED
              ? OfflineScreen()
              : data.item2 == Status.PENDING
                  ? LoadingScreen()
                  : data.item3 ? HomeScreen() : GroupScreen()
          : data.item1 == AuthStatus.RESTORING_TOKENS
              ? LoadingScreen()
              : WelcomeScreen(),
    );
  }
}
