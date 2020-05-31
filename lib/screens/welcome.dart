import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/screens/login.dart';
import 'package:sliceit/screens/register.dart';
import 'package:sliceit/utils/google_sign_in.dart';
import 'package:sliceit/widgets/dialog.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  GoogleSignInAccount _currentUser;

  @override
  initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });

      if (_currentUser != null) {
        _onGoogleSignInSuccess();
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _onGoogleSignInSuccess() async {
    try {
      GoogleSignInAuthentication authInfo = await _currentUser.authentication;
      await Provider.of<Auth>(context, listen: false)
          .googleLogin(authInfo.idToken);
    } on AuthError catch (err) {
      showErrorDialog(context, err.message);
    } catch (err) {
      showErrorDialog(context, err.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

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
                      style: theme.textTheme.headline6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    PlatformButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              height: 38.0,
                              width: 38.0,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white : null,
                                borderRadius: BorderRadius.circular(3.0),
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/google-logo.png",
                                  scale: 1,
                                  height: 18.0,
                                  width: 18.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.0),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black.withOpacity(0.54),
                              ),
                            ),
                          ),
                        ],
                      ),
                      color: theme.primaryColor,
                      android: (_) => MaterialRaisedButtonData(
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        color: isDarkMode ? Color(0xFF4285F4) : Colors.white,
                      ),
                      onPressed: _handleGoogleSignIn,
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      child: PlatformButton(
                        child: const Text(
                          'Login',
                          textAlign: TextAlign.center,
                        ),
                        color: Theme.of(context).primaryColor,
                        android: (_) => MaterialRaisedButtonData(
                          colorBrightness: Brightness.dark,
                        ),
                        onPressed: () => Navigator.of(context)
                            .pushNamed(LoginScreen.routeName),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: PlatformButton(
                        androidFlat: (_) => MaterialFlatButtonData(),
                        child: const Text('Sign up'),
                        onPressed: () => Navigator.of(context)
                            .pushNamed(RegisterScreen.routeName),
                      ),
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
