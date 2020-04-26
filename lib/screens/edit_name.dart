import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/account.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/widgets/cupertino_sized_box.dart';
import 'package:sliceit/widgets/dialog.dart';

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
  String _errorMessage;

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

  bool _validate(String firstName, String lastName) {
    bool isValid = true;
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

  void _editName() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    if (_validate(firstName, lastName)) {
      try {
        setState(() => {_isLoading = true});
        await Provider.of<AccountProvider>(context, listen: false)
            .updateAccount(
          firstName: firstName,
          lastName: lastName,
        );
        Navigator.of(context).pop();
      } on ApiError catch (err) {
        showErrorDialog(context, err.message);
      } catch (err) {
        showErrorDialog(
          context,
          'Failed to update, please check your internet connection and try again.',
        );
      } finally {
        setState(() => {_isLoading = false});
      }
    } else {
      showErrorDialog(context, _errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Edit Name'),
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
                controller: _firstNameController,
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
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_lastNameFocusNode);
                },
              ),
              const CupertinoSizedBox(height: 8),
              PlatformTextField(
                controller: _lastNameController,
                focusNode: _lastNameFocusNode,
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
