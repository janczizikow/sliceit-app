import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../services/api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _api = Api();
  final _emailController = TextEditingController();
  var _isLoading = false;

  Future<void> _showDialog({String title, String message}) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
    );
  }

  void _resetPassword() async {
    setState(() => _isLoading = true);
    final email = _emailController.text;

    try {
      await _api.resetPassword(email);
      _emailController.clear();
      _showDialog(
          title: 'Success', message: "Reset instructions were sent to $email!");
    } on ApiError catch (err) {
      _showDialog(
        title: 'Error',
        message: err.message,
      );
    } catch (err) {
      _showDialog(
        title: 'Error',
        message: 'Failed to sent email, please try again.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Enter the email address and we’ll send you instructions to reset your password.',
              ),
              const SizedBox(height: 16),
              PlatformTextField(
                autofocus: true,
                autocorrect: false,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                android: (_) => MaterialTextFieldData(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Email',
                ),
                onEditingComplete: _resetPassword,
              ),
              const SizedBox(height: 16),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                android: (_) => MaterialRaisedButtonData(
                  colorBrightness: Brightness.dark,
                ),
                child: _isLoading ? Text('Loading...') : Text('Reset password'),
                onPressed: _isLoading ? null : _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
