import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/models/group.dart';
import 'package:sliceit/models/member.dart';
import 'package:sliceit/models/share.dart';
import 'package:sliceit/providers/account.dart';
import 'package:sliceit/providers/expenses.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/utils/money_text_input_formater.dart';
import 'package:sliceit/widgets/avatar.dart';
import 'package:sliceit/widgets/card_input.dart';
import 'package:sliceit/widgets/card_picker.dart';
import 'package:sliceit/widgets/dialog.dart';
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
  List<Tuple3<Member, int, bool>> _participants;
  Member _payer;
  DateTime _date = new DateTime.now();
  bool _equalSplit = true;
  int _total = 0;
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _amountController = new TextEditingController();
    _amountController.addListener(_handleAmountChanged);
    _amountFocusNode = new FocusNode();
    final String userId =
        Provider.of<AccountProvider>(context, listen: false).account?.id;
    final List<Member> groupMembers =
        Provider.of<GroupsProvider>(context, listen: false)
            .selectedGroupMembers;
    _payer = groupMembers.firstWhere((member) => member.userId == userId);
    _participants = groupMembers.map((member) {
      return Tuple3(member, 0, true);
    }).toList();
  }

  @override
  dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _handleAmountChanged() {
    if (_amountController.value.text.isNotEmpty) {
      final int total = (double.parse(_amountController.text) * 100).toInt();
      if (_equalSplit) {
        final List<Tuple3<Member, int, bool>> activeParticipants = _participants
            .where((participation) => participation.item3)
            .toList();
        setState(() {
          _total = total;
          _participants = _participants.map((participant) {
            return participant = Tuple3(
              participant.item1,
              participant.item3
                  ? (_payer.userId == participant.item1.userId)
                      ? (total / activeParticipants.length).ceil()
                      : (total / activeParticipants.length).floor()
                  : 0,
              participant.item3,
            );
          }).toList();
        });
      } else {
        setState(() {
          _total = total;
        });
      }
    } else {
      setState(() {
        _total = 0;
        if (_equalSplit) {
          _participants = _participants.map((participant) {
            return participant = Tuple3(
              participant.item1,
              0,
              participant.item3,
            );
          }).toList();
        }
      });
    }
  }

  void _toggleEqualSplit(bool isEqualSplit) {
    if (isEqualSplit) {
      final List<Tuple3<Member, int, bool>> activeParticipants =
          _participants.where((participation) => participation.item3).toList();

      setState(() {
        _equalSplit = isEqualSplit;
        _participants = _participants.map((participant) {
          return participant = Tuple3(
            participant.item1,
            participant.item3
                ? (_payer.userId == participant.item1.userId)
                    ? (_total / activeParticipants.length).ceil()
                    : (_total / activeParticipants.length).floor()
                : 0,
            participant.item3,
          );
        }).toList();
      });
    } else {
      setState(() {
        _equalSplit = isEqualSplit;
        _participants = _participants.map((participant) {
          return participant = Tuple3(
            participant.item1,
            0,
            participant.item3,
          );
        }).toList();
      });
    }
  }

  void _toggleParticipantActive(int index, bool isActive) {
    _participants[index] = Tuple3(_participants[index].item1, 0, isActive);
    int activeParticipantsCount = _participants
        .where((participation) => participation.item3)
        .toList()
        .length;

    setState(() {
      _participants = _participants
          .asMap()
          .map((int i, participant) {
            return MapEntry(
              i,
              Tuple3(
                participant.item1,
                participant.item3
                    ? (_payer.userId == participant.item1.userId)
                        ? (_total / activeParticipantsCount).ceil()
                        : (_total / activeParticipantsCount).floor()
                    : 0,
                participant.item3,
              ),
            );
          })
          .values
          .toList();
    });
  }

  void _handleParticipantBalanceChange(int index, String value) {
    setState(() {
      _participants[index] = Tuple3(
        _participants[index].item1,
        value.isNotEmpty ? (double.parse(value) * 100).toInt() : 0,
        _participants[index].item3,
      );
    });
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
            title: const Text('Choose Payer'),
            children: members.map((member) {
              return ListTile(
                leading: Avatar(
                  initals: member.initials,
                  avatar: member.avatar,
                ),
                title: Text(member.fullName),
                onTap: () {
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
    if (payer != null) {
      setState(() {
        _payer = payer;
      });
    }
  }

  bool _validate() {
    bool isValid = true;

    if (_total == 0) {
      _errorMessage = 'You must enter the amount greater than 0';
      isValid = false;
    }

    if (_nameController.text.isEmpty) {
      _errorMessage = 'You must enter the title';
      isValid = false;
    }

    if (_equalSplit) {
      if (_participants.where((participant) => participant.item3).isEmpty) {
        _errorMessage = 'You must select at least one expense participant';
        isValid = false;
      }
    } else {
      final participantsTotal = _participants.fold(0, (acc, current) {
        return acc + (current.item2);
      });
      if (participantsTotal == 0) {
        _errorMessage = 'You must add at least one expense participant';
        isValid = false;
      }
      if (participantsTotal != _total) {
        String currency = Provider.of<GroupsProvider>(context, listen: false)
            .selectedGroup
            .currency;
        _errorMessage =
            'The amounts do not add up to the total cost of ${NumberFormat.simpleCurrency(
          name: currency,
        ).format(_total / 100)}';
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _handleAddExpense() async {
    Group group =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroup;
    assert(group != null);

    final bool isValid = _validate();

    if (!isValid) {
      showErrorDialog(context, _errorMessage);
    } else {
      try {
        List<String> participantsIds = _participants
            .where((participation) => participation.item3)
            .map((p) => p.item1.userId)
            .toList();
        await Provider.of<ExpensesProvider>(context, listen: false)
            .createExpense(
          groupId: group.id,
          currency: group.currency,
          payerId: _payer.userId,
          name: _nameController.text,
          shares: _equalSplit
              ? _participants
                  .where((participation) => participation.item3)
                  .map((p) {
                  return Share(
                      userId: p.item1.userId,
                      amount: _payer.userId == p.item1.userId
                          ? (_total / participantsIds.length).ceil()
                          : (_total / participantsIds.length).floor());
                }).toList()
              : _participants
                  .where((participation) => participation.item2 > 0)
                  .map((p) {
                  return Share(userId: p.item1.userId, amount: p.item2);
                }).toList(),
          amount: _total,
          date: _date.toIso8601String(),
        );
        Navigator.of(context).pop();
      } on ApiError catch (err) {
        showErrorDialog(context, err.message);
      } catch (e) {
        showErrorDialog(context, 'Failed to add expense!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    final currency =
        Provider.of<GroupsProvider>(context).selectedGroup.currency;
    final theme = Theme.of(context);
    final Color successColor = theme.brightness == Brightness.light
        ? Colors.green
        : Colors.greenAccent;
    final activeParticipants =
        _participants.where((participant) => participant.item3);
    final participantsTotal = _participants.fold(0, (acc, current) {
      return acc + (current.item2);
    });
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('New Expense'),
        trailingActions: <Widget>[
          PlatformButton(
            androidFlat: (_) => MaterialFlatButtonData(
              textColor: Colors.white,
            ),
            child: PlatformText('Save'),
            onPressed: _handleAddExpense,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),
                    CardInput(
                      autofocus: true,
                      controller: _nameController,
                      prefixText: 'Title',
                      hintText: 'Enter title',
                      onSubmitted: (_) {
                        if (_total == 0) {
                          FocusScope.of(context).requestFocus(_amountFocusNode);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    CardInput(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                    CardPicker(
                      prefix: 'Paid by',
                      text: _payer?.fullName ?? '',
                      onPressed: _pickPayer,
                    ),
                    SwitchListTile(
                      title: const Text('Split equally'),
                      value: _equalSplit,
                      onChanged: _toggleEqualSplit,
                    ),
                    ListTile(title: const Text('Participants')),
                    ..._participants
                        .asMap()
                        .map((int i, participant) {
                          return MapEntry(
                            i,
                            ListTile(
                              leading: Avatar(
                                initals: participant.item1.initials,
                                avatar: participant.item1.avatar,
                              ),
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      participant.item1.fullName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _equalSplit
                                      ? Text(
                                          NumberFormat.simpleCurrency(
                                            name: currency,
                                          ).format(participant.item2 / 100),
                                        )
                                      : Expanded(
                                          child: TextField(
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0.00',
                                            ),
                                            inputFormatters: [
                                              MoneyTextInputFormatter(),
                                            ],
                                            textAlign: TextAlign.right,
                                            onChanged: (String value) =>
                                                _handleParticipantBalanceChange(
                                              i,
                                              value,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              onTap: _equalSplit
                                  ? () => _toggleParticipantActive(
                                      i, !participant.item3)
                                  : null,
                              trailing: _equalSplit
                                  ? Checkbox(
                                      value: participant.item3,
                                      onChanged: (bool value) =>
                                          _toggleParticipantActive(
                                        i,
                                        value,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        })
                        .values
                        .toList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _equalSplit
                ? activeParticipants.isEmpty
                    ? ListTile(
                        title: Text(
                          'You must select at least one person to add expense',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.subtitle
                              .copyWith(color: theme.errorColor),
                        ),
                      )
                    : Container()
                : ListTile(
                    title: Text(
                      '${NumberFormat.simpleCurrency(
                        name: currency,
                      ).format(participantsTotal / 100)} of ${NumberFormat.simpleCurrency(
                        name: currency,
                      ).format(_total / 100)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      '${NumberFormat.simpleCurrency(name: currency).format((_total / 100) - participantsTotal / 100)} left',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (participantsTotal / 100) > (_total / 100)
                            ? theme.errorColor
                            : (participantsTotal == _total && _total > 0)
                                ? successColor
                                : null,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
