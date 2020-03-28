import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/platform_scaffold.dart';
import '../providers/auth.dart';

class OverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    return PlatformScaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Logout'),
          onPressed: auth.logout,
        ),
      ),
    );
  }
}
