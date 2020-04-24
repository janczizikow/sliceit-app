import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/account.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/screens/currencies_screen.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/utils/currencies.dart';
import 'package:sliceit/widgets/dialog.dart';
import 'package:sliceit/widgets/loading_dialog.dart';
import 'package:tuple/tuple.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = '/group';
  final Map<String, dynamic> arguments;

  const GroupScreen({Key key, this.arguments}) : super(key: key);

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
    setState(() => _isLoading = true);
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
      showErrorDialog(context, err.message);
      setState(() => _isLoading = true);
    } catch (err) {
      setState(() => _isLoading = true);
    }
  }

  Future<void> _deleteGroup() async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Delete group'),
        content:
            const Text('Are you sure? Deleting the group is irreversible.'),
        actions: <Widget>[
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          PlatformDialogAction(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
            ios: (_) => CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    );
    if (result) {
      showPlatformDialog(
        androidBarrierDismissible: false,
        context: context,
        builder: (_) => LoadingDialog(),
      );
      try {
        await Provider.of<GroupsProvider>(context, listen: false)
            .deleteGroup(_groupId);
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      } on ApiError catch (e) {
        Navigator.of(context).pop();
        showErrorDialog(context, e.message);
      } catch (e) {
        Navigator.of(context).pop();
        showErrorDialog(context, 'Failed to delete group');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: _groupId != null
            ? const Text('Edit group')
            : const Text('New group'),
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
                  decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              PlatformButton(
                padding: const EdgeInsets.all(0),
                androidFlat: (_) => MaterialFlatButtonData(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Currency'),
                    _currency.isNotEmpty ? Text(_currency) : const Text('N/A'),
                  ],
                ),
                onPressed: _onCurrencyPress,
              ),
              SizedBox(height: 16),
              PlatformButton(
                color: Theme.of(context).primaryColor,
                android: (_) =>
                    MaterialRaisedButtonData(colorBrightness: Brightness.dark),
                child: _isLoading
                    ? const Text('Loading...')
                    : Text(_groupId != null ? 'Save' : 'Next'),
                onPressed: _isLoading ? null : _handleSubmit,
              ),
              if (_groupId != null)
                Selector2<AccountProvider, GroupsProvider,
                    Tuple2<String, String>>(
                  selector: (_, accountState, groupsState) => Tuple2(
                    accountState.account.id,
                    groupsState.byId(_groupId).creatorId,
                  ),
                  builder: (_, data, __) {
                    return data.item1 == data.item2
                        ? PlatformButton(
                            androidFlat: (_) => MaterialFlatButtonData(
                              textColor: Theme.of(context).errorColor,
                              colorBrightness: Brightness.dark,
                            ),
                            child: const Text('Delete group'),
                            onPressed: _deleteGroup,
                          )
                        // TODO: leave group button
                        : Container();
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
