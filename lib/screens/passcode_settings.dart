import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/screens/pin_code.dart';

class PasscodeSettingsScreen extends StatefulWidget {
  static const routeName = '/passcode-settings';

  @override
  _PasscodeSettingsScreenState createState() => _PasscodeSettingsScreenState();
}

class _PasscodeSettingsScreenState extends State<PasscodeSettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final List<BiometricType> _biometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    List<BiometricType> availableBiometrics =
        await _localAuth.getAvailableBiometrics();
    _biometrics.addAll(availableBiometrics);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Auth auth = Provider.of<Auth>(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Passcode Lock'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Passcode Lock'),
              trailing: Switch(
                value: auth.isPasscodeEnabled,
                onChanged: (_) async {
                  if (auth.isPasscodeEnabled) {
                    await auth.clearPinCode();
                  } else {
                    Navigator.of(context).pushNamed(PinCodeScreen.routeName);
                  }
                },
              ),
              onTap: () async {
                if (auth.isPasscodeEnabled) {
                  await auth.clearPinCode();
                } else {
                  Navigator.of(context).pushNamed(PinCodeScreen.routeName);
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Change Passcode'),
              onTap: auth.isPasscodeEnabled
                  ? () {
                      Navigator.of(context).pushNamed(PinCodeScreen.routeName);
                    }
                  : null,
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: const Text(
                "Note: if you forget the passcode, you'll need to delete and reinstall the app.",
              ),
            ),
            if (auth.isPasscodeEnabled) const Divider(height: 1),
            if (auth.isPasscodeEnabled)
              ..._biometrics.map((biometric) {
                switch (biometric) {
                  case BiometricType.fingerprint:
                    return SwitchListTile(
                      title: const Text('Unlock with Fingerprint'),
                      value: auth.biometricAuthEnabled,
                      onChanged: (bool value) {
                        auth.biometricAuthEnabled = value;
                      },
                    );
                  case BiometricType.face:
                    return ListTile(
                      title: Text('Face id'),
                    );
                  case BiometricType.iris:
                    return Container();
                  default:
                    return Container();
                }
              }).toList(),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
