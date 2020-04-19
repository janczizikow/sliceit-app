import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/screens/offline.dart';
import 'package:tuple/tuple.dart';

import './group.dart';
import './home.dart';
import './loading.dart';
import './welcome.dart';
import '../providers/auth.dart';
import '../providers/base.dart';
import '../providers/groups.dart';

class Root extends StatelessWidget {
  static const routeName = '/';
  const Root({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector2<Auth, GroupsProvider, Tuple4<Status, bool, Status, bool>>(
      selector: (_, auth, groups) => Tuple4(
        auth.status,
        auth.isAuthenticated,
        groups.status,
        groups.hasGroups,
      ),
      builder: (_, data, __) => data.item2
          ? data.item3 == Status.REJECTED
              ? OfflineScreen()
              : data.item3 == Status.PENDING
                  ? LoadingScreen()
                  : data.item4 ? HomeScreen() : GroupScreen()
          : data.item1 == Status.PENDING ? LoadingScreen() : WelcomeScreen(),
    );
  }
}
