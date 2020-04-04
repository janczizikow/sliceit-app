import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/groups.dart';

import '../providers/auth.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_button.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  Future<void> _handleLogout(BuildContext context) async {
    Provider.of<GroupsProvider>(context, listen: false).reset();
    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Center(
        child: PlatformButton(
          child: Text('Logout'),
          materialStyle: MaterialButtonStyle.outline,
          onPressed: () => _handleLogout(context),
        ),
      ),
    );
  }
}
