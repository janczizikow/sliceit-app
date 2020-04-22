import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/auth.dart';

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
        title: const Text('Error'),
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
    } on AuthError catch (err) {
      _showErrorMessage(err.message);
    } catch (err) {
      _showErrorMessage('Failed to register');
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
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(
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
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Password',
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
