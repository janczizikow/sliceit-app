import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import './login.dart';
import './register.dart';

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png'),
                    const SizedBox(height: 32),
                    Text(
                      'Split shared expenses with ease',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.title,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    PlatformButton(
                      child: const Text('Login'),
                      color: Theme.of(context).primaryColor,
                      android: (_) => MaterialRaisedButtonData(
                        colorBrightness: Brightness.dark,
                      ),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(LoginScreen.routeName),
                    ),
                    PlatformButton(
                      androidFlat: (_) => MaterialFlatButtonData(),
                      child: const Text('Sign up'),
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
