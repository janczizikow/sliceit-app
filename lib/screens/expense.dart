import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/models/expense.dart';
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

class ExpenseScreenArguments {
  final String expenseId;

  ExpenseScreenArguments({this.expenseId});
}

class ExpenseScreen extends StatefulWidget {
  static const routeName = '/new-expense';
  final String expenseId;

  const ExpenseScreen({
    Key key,
    this.expenseId,
  }) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TextEditingController _nameController;
  TextEditingController _amountController;
  FocusNode _amountFocusNode;
  List<Tuple3<Member, int, bool>> _participants;
  Member _payer;
  DateTime _date = new DateTime.now();
  bool _equalSplit = true;
  bool _isInEditingMode = true;
  int _total = 0;
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _amountController = new TextEditingController();
    _amountFocusNode = new FocusNode();
    final GroupsProvider groupsProvider =
        Provider.of<GroupsProvider>(context, listen: false);
    final List<Member> groupMembers = groupsProvider.selectedGroupMembers;
    if (widget.expenseId == null) {
      final String userId =
          Provider.of<AccountProvider>(context, listen: false).account?.id;
      _payer = groupMembers.firstWhere((member) => member.userId == userId);
      _participants = groupMembers.map((member) {
        return Tuple3(member, 0, true);
      }).toList();
    } else {
      final Expense expense =
          Provider.of<ExpensesProvider>(context, listen: false)
              .byId(widget.expenseId);
      _total = expense.amount;
      String amountString = (expense.amount / 100).toString();
      _nameController.value = _nameController.value.copyWith(
        text: expense.name,
        selection: TextSelection(
          baseOffset: expense.name.length,
          extentOffset: expense.name.length,
        ),
        composing: TextRange.empty,
      );
      _amountController.value = _amountController.value.copyWith(
        text: amountString,
        selection: TextSelection(
          baseOffset: amountString.length,
          extentOffset: amountString.length,
        ),
        composing: TextRange.empty,
      );
      _payer = groupsProvider.selectedGroupMembers
          .firstWhere((member) => member.userId == expense.payerId);
      // TODO: Refactor nested loop
      _participants = groupMembers.map((member) {
        Share share = expense.shares.firstWhere(
            (share) => share.userId == member.userId,
            orElse: () => null);
        return Tuple3(member, share?.amount ?? 0, share != null);
      }).toList();
      _date = expense.date;
      _isInEditingMode = false;
    }
    // needs to be added after setting participants
    _amountController.addListener(_handleAmountChanged);
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

  void _toggleEditingMode() {
    setState(() {
      _isInEditingMode = !_isInEditingMode;
    });
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

    if (_total == 0) {
      _errorMessage = 'You must enter the amount greater than 0';
      isValid = false;
    }

    if (_nameController.text.isEmpty) {
      _errorMessage = 'You must enter the title';
      isValid = false;
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

  Future<void> _handleUpdateExpense() async {
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
            .updateExpense(
          groupId: group.id,
          expenseId: widget.expenseId,
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

  Future<void> _handleDeleteExpense() async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Delete expense'),
        content: const Text(
            'This will completely remove this expense for ALL people involved, not just you.'),
        actions: <Widget>[
          PlatformDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: PlatformText('Cancel'),
          ),
          PlatformDialogAction(
            child: PlatformText('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
            ios: (_) => CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    );

    if (result) {
      showLoadingDialog(context);
      try {
        await Provider.of<ExpensesProvider>(context, listen: false)
            .deleteExpense(widget.expenseId);
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      } on ApiError catch (e) {
        Navigator.of(context).pop();
        showErrorDialog(context, e.message);
      } catch (e) {
        Navigator.of(context).pop();
        showErrorDialog(context, 'Failed to delete expense');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final bool isNewExpense = widget.expenseId == null;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(isNewExpense ? 'New Expense' : 'Expense'),
        trailingActions: <Widget>[
          PlatformButton(
            androidFlat: (_) => MaterialFlatButtonData(
              textColor: Colors.white,
            ),
            child: PlatformText(_isInEditingMode ? 'Save' : 'Edit'),
            onPressed: _isInEditingMode
                ? isNewExpense ? _handleAddExpense : _handleUpdateExpense
                : _toggleEditingMode,
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
                      enabled: _isInEditingMode,
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
                      enabled: _isInEditingMode,
                      inputFormatters: [
                        MoneyTextInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CardPicker(
                      prefix: 'Date',
                      text: DateFormat.yMMMd().format(_date),
                      onPressed: _isInEditingMode ? _pickDate : null,
                    ),
                    const SizedBox(height: 16),
                    CardPicker(
                      prefix: 'Paid by',
                      text: _payer?.fullName ?? '',
                      onPressed: _isInEditingMode ? _pickPayer : null,
                    ),
                    if (_isInEditingMode)
                      SwitchListTile(
                        title: const Text('Split equally'),
                        value: _equalSplit,
                        onChanged: _toggleEqualSplit,
                      ),
                    ListTile(title: const Text('Participants')),
                    ..._participants
                        .asMap()
                        .map((int i, participant) {
                          // Don't show in active participants in Expense detail
                          // if not in editing mode
                          if (!_isInEditingMode &&
                              !isNewExpense &&
                              !participant.item3) {
                            return MapEntry(i, Container());
                          }

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
                              onTap: (_equalSplit && _isInEditingMode)
                                  ? () => _toggleParticipantActive(
                                      i, !participant.item3)
                                  : null,
                              trailing: (_equalSplit && _isInEditingMode)
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
                    if (widget.expenseId != null)
                      PlatformButton(
                        androidFlat: (_) => MaterialFlatButtonData(
                          colorBrightness: Brightness.dark,
                        ),
                        child: Text(
                          'Delete Expense',
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        onPressed: _handleDeleteExpense,
                      ),
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
