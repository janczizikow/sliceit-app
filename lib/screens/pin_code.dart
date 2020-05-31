import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';

class PinCodeScreen extends StatefulWidget {
  static const routeName = '/pin-code';

  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _pinController;
  String _pin;
  bool _pinVerified = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _pinController.addListener(_handleChange);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _showError() async {
    _pinController.clear();
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: Text(
          _pin != null ? "Passcodes don't match" : "Passcode must be 4 digits",
        ),
      ),
    );
    await HapticFeedback.vibrate();
  }

  void _handleChange() {
    String pin = _pinController.text;
    if (_pin == null) {
      if (pin.length == 4) {
        setState(() {
          _pin = pin;
        });
        _pinController.clear();
      }
    } else {
      if (pin.length == 4) {
        if (pin == _pin) {
          _pinVerified = true;
          _setPinCode();
        } else {
          _showError();
        }
      }
    }
  }

  Future<void> _setPinCode() async {
    if (_pinVerified) {
      await Provider.of<Auth>(context, listen: false).setPinCode(_pin);
      _pinController.clear();
      Navigator.of(context).pop();
    } else {
      _showError();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isConfirming = _pin != null;

    return PlatformScaffold(
      android: (context) => MaterialScaffoldData(
        widgetKey: _scaffoldKey,
      ),
      appBar: PlatformAppBar(
        trailingActions: <Widget>[
          PlatformIconButton(
            iosIcon: const Icon(CupertinoIcons.check_mark),
            androidIcon: const Icon(Icons.check),
            onPressed: _isConfirming ? _setPinCode : _showError,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
          child: Column(
            children: <Widget>[
              Text(
                _isConfirming
                    ? 'Re-enter your new passcode'
                    : 'Enter a passcode',
              ),
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
    );
  }
}
