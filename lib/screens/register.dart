import 'package:flutter/material.dart';

import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Register'),
        ],
      ),
    );
  }
}
