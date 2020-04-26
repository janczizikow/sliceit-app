import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/screens/forgot_password.dart';
import 'package:sliceit/utils/constants.dart';
import 'package:sliceit/widgets/cupertino_sized_box.dart';
import 'package:sliceit/widgets/dialog.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode _passwordFocusNode;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage;

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

  bool _validate(String email, String password) {
    bool isValid = true;

    if (password.length < 8) {
      _errorMessage = 'Password must be at least 8 characters long';
      isValid = false;
    }

    if (EMAIL_REGEX.hasMatch(email)) {
      return isValid;
    } else {
      _errorMessage = 'Invalid email address';
      isValid = false;
    }

    return isValid;
  }

  Future<void> _authenticate() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_validate(email, password)) {
      try {
        await Provider.of<Auth>(context, listen: false)
            .login(email: email, password: password);
      } on AuthError catch (err) {
        showErrorDialog(context, err.message);
      } catch (err) {
        showErrorDialog(context, 'Failed to authenticate');
      }
    } else {
      showErrorDialog(context, _errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Login'),
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
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Email',
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              const CupertinoSizedBox(height: 8),
              PlatformTextField(
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
                textInputAction: TextInputAction.go,
                android: (_) => MaterialTextFieldData(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Password',
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                focusNode: _passwordFocusNode,
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 16),
              Selector<Auth, AuthStatus>(
                selector: (_, auth) => auth.status,
                builder: (_, status, __) => PlatformButton(
                  color: Theme.of(context).primaryColor,
                  ios: (_) => CupertinoButtonData(
                    padding: EdgeInsets.zero,
                  ),
                  android: (_) => MaterialRaisedButtonData(
                    colorBrightness: Brightness.dark,
                  ),
                  child: status == AuthStatus.AUTHENTICATING
                      ? const Text('Loading...')
                      : const Text('Login'),
                  onPressed: status == AuthStatus.AUTHENTICATING
                      ? null
                      : _authenticate,
                ),
              ),
              PlatformButton(
                androidFlat: (_) => MaterialFlatButtonData(),
                child: const Text('Forgot password?'),
                onPressed: _forgotPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
