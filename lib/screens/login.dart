import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/platform_appbar.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_text_field.dart';
import '../widgets/platform_button.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordFocusNode = FocusNode();

  void _authenticate() {
    // TODO: HANDLE AUTH
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              PlatformTextField(
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'email',
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              PlatformTextField(
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  labelText: 'password',
                ),
                focusNode: _passwordFocusNode,
              ),
              PlatformButton(
                child: Text('Login'),
                onPressed: _authenticate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
