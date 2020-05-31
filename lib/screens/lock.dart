import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';

class LockScreenArguments {
  final bool popIfValid;

  LockScreenArguments({this.popIfValid});
}

class LockScreen extends StatefulWidget {
  static const routeName = '/lock-screen';
  final bool popIfValid;

  const LockScreen({
    Key key,
    this.popIfValid = false,
  }) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_handleChange);

    if (Provider.of<Auth>(context, listen: false).biometricAuthEnabled) {
      biometricAuthentication();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _showError() async {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: const Text("Invalid passcode"),
      ),
    );
    await HapticFeedback.vibrate();
  }

  void _handleChange() {
    String pin = _pinController.text;
    Auth auth = Provider.of<Auth>(context, listen: false);
    if (pin.length == 4) {
      bool isValid = auth.checkPinCode(pin);
      if (isValid) {
        _pinController.clear();
        if (widget.popIfValid) {
          Navigator.of(context).pop();
        } else {
          auth.pinCodeVerified();
        }
      } else {
        _showError();
        _pinController.clear();
      }
    }
  }

  Future<void> biometricAuthentication() async {
    try {
      bool didAuthenticate = await _localAuth.authenticateWithBiometrics(
        localizedReason: 'Scan your fingerprint to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if (didAuthenticate) {
        if (widget.popIfValid) {
          Navigator.of(context)
              .popUntil((route) => route.settings.name != LockScreen.routeName);
        } else {
          Provider.of<Auth>(context, listen: false).pinCodeVerified();
        }
      }
    } catch (err) {
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: PlatformScaffold(
        android: (context) => MaterialScaffoldData(
          widgetKey: _scaffoldKey,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Enter the passcode'),
                PlatformTextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  controller: _pinController,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
