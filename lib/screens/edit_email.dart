import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/account.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/utils/constants.dart';
import 'package:sliceit/widgets/dialog.dart';

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

  bool _validate(String email) {
    if (EMAIL_REGEX.hasMatch(email)) {
      return true;
    } else {
      return false;
    }
  }

  void _editName() async {
    final email = _emailController.text;

    if (_validate(email)) {
      try {
        setState(() => {_isLoading = true});
        await Provider.of<AccountProvider>(context, listen: false)
            .updateAccount(
          email: email,
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
      showErrorDialog(context, 'Invalid email address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Edit Email'),
        trailingActions: <Widget>[
          PlatformIconButton(
            iosIcon: const Icon(CupertinoIcons.check_mark),
            androidIcon: const Icon(Icons.check),
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
