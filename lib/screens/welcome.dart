import 'package:flutter/material.dart';

import './login.dart';
import './register.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    PlatformButton(
                      child: Text('Login'),
                      color: Theme.of(context).primaryColor,
                      colorBrightness: Brightness.dark,
                      onPressed: () => Navigator.of(context)
                          .pushNamed(LoginScreen.routeName),
                    ),
                    PlatformButton(
                      materialStyle: MaterialButtonStyle.flat,
                      child: Text('Sign up'),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(RegisterScreen.routeName),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
