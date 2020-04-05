import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/groups.dart';

import '../providers/auth.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_button.dart';
import '../widgets/platform_alert_dialog.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleLogout() async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        cancelText: 'Cancel',
        confirmText: 'Logout',
      ),
    );
    if (result) {
      Provider.of<GroupsProvider>(context, listen: false).reset();
      await Provider.of<Auth>(context, listen: false).logout();
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Center(
        child: PlatformButton(
          child: Text('Logout'),
          materialStyle: MaterialButtonStyle.outline,
          onPressed: _handleLogout,
        ),
      ),
    );
  }
}
