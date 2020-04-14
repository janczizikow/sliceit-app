import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import './forgot_password.dart';
import '../services/api.dart';
import '../providers/auth.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode _passwordFocusNode;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorMessage(String message) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
    );
  }

  void _forgotPassword() {
    Navigator.of(context).pushNamed(ForgotPasswordScreen.routeName);
  }

  void _handleSubmit() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    _authenticate();
  }

  Future<void> _authenticate() async {
    // TODO: Validation
    String email = _emailController.text;
    String password = _passwordController.text;
    try {
      await Provider.of<Auth>(context, listen: false)
          .login(email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } on ApiError catch (err) {
      _showErrorMessage(err.message);
    } catch (err) {
      _showErrorMessage('Failed to authenticate');
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
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Email',
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
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Password',
                ),
                focusNode: _passwordFocusNode,
                onSubmitted: (_) => _handleSubmit(),
              ),
              SizedBox(height: 16),
              Selector<Auth, bool>(
                selector: (_, auth) => auth.isFetching,
                builder: (_, isFetching, __) => PlatformButton(
                  color: Theme.of(context).primaryColor,
                  android: (_) => MaterialRaisedButtonData(
                    colorBrightness: Brightness.dark,
                  ),
                  child: isFetching ? Text('Loading...') : Text('Login'),
                  onPressed: isFetching ? null : _authenticate,
                ),
              ),
              PlatformButton(
                androidFlat: (_) => MaterialFlatButtonData(),
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
