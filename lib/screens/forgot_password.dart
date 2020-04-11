import 'package:flutter/material.dart';

import '../services/api.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_alert_dialog.dart';
import '../widgets/platform_text_field.dart';
import '../widgets/platform_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final _api = Api();
  final _emailController = TextEditingController();
  var _isLoading = false;

  void _showDialog({String title, String message}) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
    });
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Reset password'),
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
              SizedBox(
                height: 16,
              ),
              PlatformTextField(
                autocorrect: false,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                onEditingComplete: _resetPassword,
              ),
              SizedBox(
                height: 16,
              ),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                colorBrightness: Brightness.dark,
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
