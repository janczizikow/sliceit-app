import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/services/api.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import './currencies_screen.dart';
import '../providers/groups.dart';
import '../utils/currencies.dart';

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
  final List<Currency> _currencies =
      currencies.entries.map((entry) => Currency.fromMap(entry.value)).toList();

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
        actions: <Widget>[
          PlatformDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _onCurrencyPress() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      showCupertinoModalPopup(
          context: context, builder: (_) => _buildBottomPicker());
    } else {
      Map results = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CurrenciesScreen(_currencies),
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
    }
  }

  Widget _buildBottomPicker() {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 22,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: CupertinoPicker.builder(
              itemExtent: 32.0,
              backgroundColor:
                  CupertinoColors.systemBackground.resolveFrom(context),
              childCount: _currencies.length,
              itemBuilder: (_, i) =>
                  Text("${_currencies[i].code} - ${_currencies[i].name}"),
              onSelectedItemChanged: (i) => {
                setState(() {
                  _currency = _currencies[i].code;
                })
              },
            ),
          ),
        ),
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
                android: (_) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                ios: (_) => CupertinoTextFieldData(
                  placeholder: 'Name',
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
              PlatformButton(
                padding: const EdgeInsets.all(0),
                androidFlat: (_) => MaterialFlatButtonData(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Currency'),
                    _currency.isNotEmpty ? Text(_currency) : Text('N/A'),
                  ],
                ),
                onPressed: _onCurrencyPress,
              ),
              SizedBox(height: 16),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                android: (_) =>
                    MaterialRaisedButtonData(colorBrightness: Brightness.dark),
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
