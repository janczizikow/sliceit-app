import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../providers/auth.dart';
import '../services/api.dart';

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

  void _handleSubmit() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    _register();
  }

  void _register() async {
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
    } catch (err) {
      _showErrorMessage('Failed to register');
    }
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
                autofocus: true,
                controller: _firstNameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'First name',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'First name',
                ),
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_lastNameFocusNode),
              ),
              PlatformTextField(
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'Last name',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Last name',
                ),
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocusNode),
              ),
              PlatformTextField(
                autocorrect: false,
                controller: _emailController,
                focusNode: _emailFocusNode,
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
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
              ),
              PlatformTextField(
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.go,
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Password',
                ),
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
                  child: isFetching ? Text('Loading...') : Text('Register'),
                  onPressed: isFetching ? null : _register,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
