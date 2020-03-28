import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Login'),
          onPressed: auth.login,
        ),
      ),
    );
  }
}
