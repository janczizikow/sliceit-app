import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/models/group.dart';
import 'package:sliceit/models/member.dart';
import 'package:sliceit/providers/account.dart';
import 'package:sliceit/providers/expenses.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/utils/money_text_input_formater.dart';
import 'package:sliceit/widgets/avatar.dart';
import 'package:sliceit/widgets/card_input.dart';
import 'package:sliceit/widgets/card_picker.dart';
import 'package:tuple/tuple.dart';

class NewExpenseScreen extends StatefulWidget {
  static const routeName = '/new-expense';

  const NewExpenseScreen({
    Key key,
  }) : super(key: key);

  @override
  _NewExpenseScreenState createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  TextEditingController _nameController;
  TextEditingController _amountController;
  FocusNode _amountFocusNode;
  List<Tuple2<Member, bool>> _participants;
  Member _payer;
  DateTime _date = new DateTime.now();
  bool _equalSplit = true;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _amountController = new TextEditingController();
    _amountFocusNode = new FocusNode();
    final String userId =
        Provider.of<AccountProvider>(context, listen: false).account?.id;
    final List<Member> groupMembers =
        Provider.of<GroupsProvider>(context, listen: false)
            .selectedGroupMembers;
    _payer = groupMembers.firstWhere((member) => member.userId == userId);
    _participants = groupMembers.map((member) {
      return Tuple2(member, true);
    }).toList();
  }

  @override
  dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
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

  Future<void> _pickDate() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // TODO: iOS date picker
    } else {
      DateTime newDate = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (newDate != null && !newDate.isAtSameMomentAs(_date)) {
        setState(() {
          _date = newDate;
        });
      }
    }
  }

  Future<Member> _pickMember() async {
    List<Member> members = Provider.of<GroupsProvider>(context, listen: false)
        .selectedGroupMembers;
    Member member = await showDialog<Member>(
        context: context,
        builder: (_) {
          return SimpleDialog(
            children: members.map((member) {
              return SimpleDialogOption(
                child: Text(member.fullName),
                onPressed: () {
                  Navigator.of(context).pop(member);
                },
              );
            }).toList(),
          );
        });
    return member;
  }

  Future<void> _pickPayer() async {
    Member payer = await _pickMember();
    setState(() {
      _payer = payer;
    });
  }

  Future<void> _handleAddExpense() async {
    Group group =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroup;
    if (group != null) {
      try {
        final int total = (double.parse(_amountController.text) * 100).toInt();
        List<String> participantsIds = _participants
            .where((participation) => participation.item2)
            .map((p) => p.item1.userId)
            .toList();
        await Provider.of<ExpensesProvider>(context, listen: false)
            .createExpense(
          groupId: group.id,
          currency: group.currency,
          payerId: _payer.userId,
          name: _nameController.text,
          shares: participantsIds.map((id) {
            return {
              'userId': id,
              'amount': _payer.userId == id
                  ? (total / participantsIds.length).ceil()
                  : (total / participantsIds.length).floor()
            };
          }).toList(),
          amount: total,
          date: _date.toIso8601String(),
        );
        Navigator.of(context).pop();
      } on ApiError catch (err) {
        _showErrorMessage(err.message);
      } catch (e) {
        _showErrorMessage('Failed to add expense!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GroupsProvider, List<Member>>(
      selector: (_, groups) => groups.selectedGroupMembers,
      builder: (_, members, __) => PlatformScaffold(
        appBar: PlatformAppBar(
          trailingActions: <Widget>[
            PlatformButton(
              androidFlat: (_) => MaterialFlatButtonData(
                textColor: Colors.white,
              ),
              child: PlatformText('Add'),
              onPressed: _handleAddExpense,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16),
                CardInput(
                  autofocus: true,
                  controller: _nameController,
                  prefixText: 'Name',
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_amountFocusNode);
                  },
                ),
                CardInput(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixText: 'Amount',
                  hintText: '0.00',
                  inputFormatters: [
                    MoneyTextInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                CardPicker(
                  prefix: 'Date',
                  text: DateFormat.yMMMd().format(_date),
                  onPressed: _pickDate,
                ),
                const SizedBox(height: 16),
                // TODO: HANDLE UNEVEN SPLITS
                // SwitchListTile(
                //   title: const Text('Split equally'),
                //   value: _equalSplit,
                //   onChanged: (bool value) {
                //     setState(() {
                //       _equalSplit = value;
                //     });
                //   },
                // ),
                CardPicker(
                  prefix: 'Paid by',
                  text: _payer?.fullName ?? '',
                  onPressed: _pickPayer,
                ),
                ListTile(title: const Text('Participants')),
                ..._participants
                    .asMap()
                    .map((int i, participant) {
                      return MapEntry(
                        i,
                        CheckboxListTile(
                          title: Text(participant.item1.fullName),
                          value: participant.item2,
                          onChanged: (bool value) {
                            setState(() {
                              _participants[i] =
                                  Tuple2(participant.item1, value);
                            });
                          },
                          secondary: Avatar(
                            initals: participant.item1.initials,
                            avatar: participant.item1.avatar,
                          ),
                        ),
                      );
                    })
                    .values
                    .toList(),
                const SizedBox(height: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
