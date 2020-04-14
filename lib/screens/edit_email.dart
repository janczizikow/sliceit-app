import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../services/api.dart';
import '../providers/account.dart';

class EditEmailScreen extends StatefulWidget {
  static const routeName = '/edit-email';

  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmailScreen> {
  final _emailController = TextEditingController();
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    final email =
        Provider.of<AccountProvider>(context, listen: false).account.email;
    _emailController.value = _emailController.value.copyWith(
      text: email,
      selection: TextSelection(
        baseOffset: email.length,
        extentOffset: email.length,
      ),
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
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

  void _editName() async {
    setState(() => {_isLoading = true});
    // TODO: validaton
    final email = _emailController.text;

    try {
      await Provider.of<AccountProvider>(context, listen: false).updateAccount(
        email: email,
      );
      Navigator.of(context).pop();
    } on ApiError catch (err) {
      _showErrorMessage(err.message);
    } catch (err) {
      _showErrorMessage(
          'Failed to update, please check your internet connection and try again.');
    } finally {
      setState(() => {_isLoading = false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text('Edit Email'),
        trailingActions: <Widget>[
          PlatformIconButton(
            iosIcon: Icon(CupertinoIcons.check_mark),
            androidIcon: Icon(Icons.check),
            onPressed: _isLoading ? null : _editName,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PlatformTextField(
                autofocus: true,
                controller: _emailController,
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Email',
                ),
                onSubmitted: (_) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  _editName();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
