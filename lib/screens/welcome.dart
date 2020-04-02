import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/screens/login.dart';
import 'package:sliceit/screens/register.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'openid',
  ],
);

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  GoogleSignInAccount _currentUser;

  @override
  initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        // TODO: show a loading indicator
        _onGoogleSignInSuccess();
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _onGoogleSignInSuccess() async {
    try {
      GoogleSignInAuthentication authInfo = await _currentUser.authentication;
      // FIXME: `authInfo.idToken` is always null
      // https://github.com/flutter/flutter/issues/16613#issuecomment-490494672
      print(authInfo.idToken);
      await Provider.of<Auth>(context, listen: false)
          .googleLogin(authInfo.idToken);
    } on AuthError catch (err) {
      print(err);
    } catch (err) {
      print(err);
    }
  }

  Future<void> _handleGoogleSignOut() => _googleSignIn.disconnect();

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
                      child: const Text('Sign in with Google'),
                      color: Theme.of(context).primaryColor,
                      android: (_) => MaterialRaisedButtonData(
                        colorBrightness: Brightness.dark,
                      ),
                      onPressed: _handleGoogleSignIn,
                    ),
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
