import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/utils/constants.dart';
import 'package:sliceit/widgets/cupertino_sized_box.dart';
import 'package:sliceit/widgets/dialog.dart';

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

  FocusNode _lastNameFocusNode;
  FocusNode _emailFocusNode;
  FocusNode _passwordFocusNode;
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _lastNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    _register();
  }

  bool _validate({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) {
    bool isValid = true;

    if (password.length < 8) {
      _errorMessage = 'Password must be at least 8 characters long';
      isValid = false;
    }

    if (EMAIL_REGEX.hasMatch(email)) {
      return isValid;
    } else {
      isValid = false;
      _errorMessage = 'Invalid email address';
    }

    if (lastName.isEmpty) {
      isValid = false;
      _errorMessage = 'Last name cannot be empty';
    }

    if (firstName.isEmpty) {
      isValid = false;
      _errorMessage = 'First name cannot be empty';
    }

    return isValid;
  }

  void _register() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_validate(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    )) {
      try {
        await Provider.of<Auth>(context, listen: false).register(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
        );
      } on AuthError catch (err) {
        showErrorDialog(context, err.message);
      } catch (err) {
        showErrorDialog(context, 'Failed to register');
      }
    } else {
      showErrorDialog(context, _errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Sign up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PlatformTextField(
                autofocus: true,
                controller: _firstNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                android: (_) => MaterialTextFieldData(
                  decoration: const InputDecoration(
                    labelText: 'First name',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'First name',
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_lastNameFocusNode),
              ),
              const CupertinoSizedBox(height: 8),
              PlatformTextField(
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                android: (_) => MaterialTextFieldData(
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Last name',
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocusNode),
              ),
              const CupertinoSizedBox(height: 8),
              PlatformTextField(
                autocorrect: false,
                controller: _emailController,
                focusNode: _emailFocusNode,
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
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
              ),
              const CupertinoSizedBox(height: 8),
              PlatformTextField(
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
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
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 16),
              Selector<Auth, AuthStatus>(
                selector: (_, auth) => auth.status,
                builder: (_, status, __) => PlatformButton(
                  color: Theme.of(context).primaryColor,
                  android: (_) => MaterialRaisedButtonData(
                    colorBrightness: Brightness.dark,
                  ),
                  child: status == AuthStatus.AUTHENTICATING
                      ? const Text('Loading...')
                      : const Text('Register'),
                  onPressed:
                      status == AuthStatus.AUTHENTICATING ? null : _register,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
