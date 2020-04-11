import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/services/api.dart';

import './currencies_screen.dart';
import '../providers/groups.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_text_field.dart';
import '../widgets/platform_button.dart';
import '../widgets/platform_alert_dialog.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = '/group';
  final Map<String, dynamic> arguments;

  GroupScreen({this.arguments});

  @override
  State<StatefulWidget> createState() => _GroupState();
}

class _GroupState extends State<GroupScreen> {
  bool _isLoading = false;
  String _groupId;
  final _nameController = TextEditingController();
  String _currency = '';

  @override
  void initState() {
    super.initState();
    if (widget.arguments?.containsKey('groupId') ?? false) {
      _groupId = widget.arguments['groupId'];
      _nameController.value = _nameController.value.copyWith(
        text: widget.arguments['name'],
        selection: TextSelection(
            baseOffset: widget.arguments['name'].length,
            extentOffset: widget.arguments['name'].length),
        composing: TextRange.empty,
      );
      _currency = widget.arguments['currency'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
    });
    // TODO: validation
    String name = _nameController.text;
    try {
      if (_groupId != null) {
        await Provider.of<GroupsProvider>(context, listen: false)
            .updateGroup(groupId: _groupId, name: name, currency: _currency);
        Navigator.of(context).pop();
      } else {
        await Provider.of<GroupsProvider>(context, listen: false)
            .createGroup(name: name, currency: _currency);
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } on ApiError catch (err) {
      _showErrorMessage(err.message);
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: _groupId != null ? Text('Edit group') : Text('New group'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PlatformTextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                controller: _nameController,
                onSubmitted: (_) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Text('Currency'),
                trailing: _currency.isNotEmpty ? Text(_currency) : Text('N/A'),
                onTap: () async {
                  Map results = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CurrenciesScreen(),
                      settings: RouteSettings(arguments: {
                        'code': _currency,
                      }),
                    ),
                  );
                  if (results != null && results.containsKey('code')) {
                    setState(() {
                      _currency = results['code'];
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                colorBrightness: Brightness.dark,
                child: _isLoading ? Text('Loading...') : Text('Next'),
                onPressed: _isLoading ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
