import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/screens/edit_group.dart';
import 'package:sliceit/screens/home.dart';
import 'package:sliceit/screens/loading.dart';
import 'package:sliceit/screens/lock.dart';
import 'package:sliceit/screens/offline.dart';
import 'package:sliceit/screens/welcome.dart';
import 'package:tuple/tuple.dart';

class Root extends StatelessWidget {
  static const routeName = '/';
  const Root({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector2<Auth, GroupsProvider,
        Tuple4<AuthStatus, PasscodeStatus, Status, bool>>(
      selector: (_, auth, groups) => Tuple4(
        auth.status,
        auth.passcodeStatus,
        groups.status,
        groups.isNotEmpty,
      ),
      builder: (_, data, __) => data.item1 == AuthStatus.AUTHENTICATED
          ? data.item2 == PasscodeStatus.ENABLED
              ? LockScreen()
              : data.item3 == Status.REJECTED
                  ? OfflineScreen()
                  : data.item3 == Status.PENDING
                      ? LoadingScreen()
                      : data.item4 ? HomeScreen() : EditGroupScreen()
          : data.item1 == AuthStatus.RESTORING_TOKENS
              ? LoadingScreen()
              : WelcomeScreen(),
    );
  }
}
