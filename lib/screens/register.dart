import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../services/api.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_alert_dialog.dart';
import '../widgets/platform_text_field.dart';
import '../widgets/platform_button.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading = false;

  void _showErrorMessage(String message) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: 'Error',
        message: message,
      ),
    );
  }

  void _register() async {
    setState(() {
      _isLoading = true;
    });
    // TODO: Validation
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    try {
      await Provider.of<Auth>(context, listen: false).register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } on ApiError catch (err) {
      _showErrorMessage(err.message);
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      _showErrorMessage('Failed to register');
      setState(() {
        _isLoading = false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Sign up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PlatformTextField(
                controller: _firstNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'First name',
                ),
              ),
              PlatformTextField(
                controller: _lastNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Last name',
                ),
              ),
              PlatformTextField(
                autocorrect: false,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              PlatformTextField(
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                colorBrightness: Brightness.dark,
                child: _isLoading ? Text('Loading...') : Text('Register'),
                onPressed: _isLoading ? null : _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
