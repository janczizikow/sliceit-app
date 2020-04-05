import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/services/api.dart';

import './forgot_password.dart';
import '../providers/auth.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_alert_dialog.dart';
import '../widgets/platform_text_field.dart';
import '../widgets/platform_button.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorMessage(String message) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: 'Error',
        message: message,
      ),
    );
  }

  void _forgotPassword() {
    Navigator.of(context).pushNamed(ForgotPasswordScreen.routeName);
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
    });
    // TODO: Validation
    String email = _emailController.text;
    String password = _passwordController.text;
    try {
      await Provider.of<Auth>(context, listen: false)
          .login(email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } on ApiError catch (err) {
      _showErrorMessage(err.message);
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      _showErrorMessage('Failed to authenticate');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PlatformTextField(
                autofocus: true,
                autocorrect: false,
                controller: _emailController,
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
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  labelText: 'password',
                ),
                focusNode: _passwordFocusNode,
              ),
              SizedBox(
                height: 16,
              ),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                colorBrightness: Brightness.dark,
                child: _isLoading ? Text('Loading...') : Text('Login'),
                onPressed: _isLoading ? null : _authenticate,
              ),
              PlatformButton(
                materialStyle: MaterialButtonStyle.flat,
                child: Text('Forgot password?'),
                onPressed: _forgotPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
