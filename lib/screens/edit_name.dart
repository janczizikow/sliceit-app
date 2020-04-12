import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api.dart';
import '../providers/account.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_alert_dialog.dart';
import '../widgets/platform_text_field.dart';

class EditNameScreen extends StatefulWidget {
  static const routeName = '/edit-name';

  @override
  _EditNameState createState() => _EditNameState();
}

class _EditNameState extends State<EditNameScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  FocusNode _lastNameFocusNode;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    final account =
        Provider.of<AccountProvider>(context, listen: false).account;
    final firstName = account.firstName;
    final lastName = account.lastName;
    _firstNameController.value = _firstNameController.value.copyWith(
      text: firstName,
      selection: TextSelection(
        baseOffset: firstName.length,
        extentOffset: firstName.length,
      ),
      composing: TextRange.empty,
    );
    _lastNameController.value = _lastNameController.value.copyWith(
      text: lastName,
      selection: TextSelection(
        baseOffset: lastName.length,
        extentOffset: lastName.length,
      ),
      composing: TextRange.empty,
    );
    _lastNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _lastNameFocusNode.dispose();
    super.dispose();
  }

  void _showErrorMessage(String message) async {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Error'),
        content: Text(message),
      ),
    );
  }

  void _editName() async {
    setState(() => {_isLoading = true});
    // TODO: validaton
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    try {
      await Provider.of<AccountProvider>(context, listen: false).updateAccount(
        firstName: firstName,
        lastName: lastName,
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
        title: Text('Edit Name'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
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
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'First name',
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_lastNameFocusNode);
                },
              ),
              PlatformTextField(
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
                decoration: InputDecoration(
                  labelText: 'Last name',
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
