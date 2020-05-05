import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/models/expense.dart';
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
import 'package:sliceit/widgets/dialog.dart';

class PaymentScreenArguments {
  final String expenseId;

  PaymentScreenArguments({this.expenseId});
}

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  final String expenseId;

  const PaymentScreen({Key key, this.expenseId}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController _amountController;
  FocusNode _amountFocusNode;
  Member _from;
  Member _to;
  DateTime _date = new DateTime.now();
  bool _isInEditingMode = true;
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = new TextEditingController();
    _amountFocusNode = FocusNode();
    if (widget.expenseId == null) {
      final String userId =
          Provider.of<AccountProvider>(context, listen: false).account?.id;
      final List<Member> groupMembers =
          Provider.of<GroupsProvider>(context, listen: false)
              .selectedGroupMembers;
      final currentMemberIndex =
          groupMembers.indexWhere((member) => member.userId == userId);
      if (currentMemberIndex != -1) {
        _from = groupMembers[currentMemberIndex];
        if (groupMembers.length == 2) {
          _to = groupMembers[currentMemberIndex == 0 ? 1 : 0];
        }
      }
    } else {
      final Expense payment =
          Provider.of<ExpensesProvider>(context, listen: false)
              .byId(widget.expenseId);
      String amountString = (payment.amount / 100).toString();
      _amountController.value = _amountController.value.copyWith(
        text: amountString,
        selection: TextSelection(
          baseOffset: amountString.length,
          extentOffset: amountString.length,
        ),
        composing: TextRange.empty,
      );
      _from = Provider.of<GroupsProvider>(context, listen: false)
          .selectedGroupMembers
          .firstWhere((member) => member.userId == payment.payerId);
      String toUserId = payment.shares
          .firstWhere((share) => share.userId != payment.payerId)
          .userId;
      _to = Provider.of<GroupsProvider>(context, listen: false)
          .selectedGroupMembers
          .firstWhere((member) => member.userId == toUserId);
      _isInEditingMode = false;
      _date = payment.date;
    }
  }

  @override
  dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _toggleEditingMode() {
    setState(() {
      _isInEditingMode = !_isInEditingMode;
    });
  }

  Future<Member> _pickMember(List<Member> members) async {
    Member member = await showDialog<Member>(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: const Text('Choose Member'),
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

  Future<void> _pickFrom() async {
    List<Member> groupMembers =
        Provider.of<GroupsProvider>(context, listen: false)
            .selectedGroupMembers;
    Member member = await _pickMember(groupMembers);
    if (member != null) {
      setState(() {
        _from = member;
        if (groupMembers.length == 2) {
          _to = groupMembers.firstWhere((m) => m.id != member.id);
        }
      });
    }
  }

  Future<void> _pickTo() async {
    List<Member> groupMembers =
        Provider.of<GroupsProvider>(context, listen: false)
            .selectedGroupMembers;
    Member member = await _pickMember(groupMembers);
    if (member != null) {
      setState(() {
        _to = member;
        if (groupMembers.length == 2) {
          _from = groupMembers.firstWhere((m) => m.id != member.id);
        }
      });
    }
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

  bool _validate() {
    bool isValid = true;

    if (_from == null) {
      _errorMessage = 'You must select payer';
      isValid = false;
    }

    if (_to == null) {
      _errorMessage = 'You must select who received the payment';
      isValid = false;
    }

    if (_from.userId == _to.userId) {
      _errorMessage =
          'Payer and receiver are the same person! Select two different persons.';
      isValid = false;
    }

    if (_amountController.text.isEmpty) {
      _errorMessage = 'You must enter the amount';
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleAddPayment() async {
    Group group =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroup;
    assert(group != null);

    final bool isValid = _validate();

    if (!isValid) {
      showErrorDialog(context, _errorMessage);
    } else {
      try {
        await Provider.of<ExpensesProvider>(context, listen: false)
            .createPayment(
          groupId: group.id,
          currency: group.currency,
          amount: (double.parse(_amountController.text) * 100).toInt(),
          from: _from.userId,
          to: _to.userId,
          date: _date.toIso8601String(),
        );
        Navigator.of(context).pop();
      } on ApiError catch (err) {
        showErrorDialog(context, err.message);
      } catch (e) {
        showErrorDialog(context, 'Failed to add payment!');
      }
    }
  }

  Future<void> _handleUpdatePayment() async {
    Group group =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroup;
    assert(group != null);
    final bool isValid = _validate();

    if (!isValid) {
      showErrorDialog(context, _errorMessage);
    } else {
      try {
        await Provider.of<ExpensesProvider>(context, listen: false)
            .updatePayment(
          groupId: group.id,
          expenseId: widget.expenseId,
          currency: group.currency,
          amount: (double.parse(_amountController.text) * 100).toInt(),
          from: _from.userId,
          to: _to.userId,
          date: _date.toIso8601String(),
        );
        Navigator.of(context).pop();
      } on ApiError catch (err) {
        showErrorDialog(context, err.message);
      } catch (e) {
        showErrorDialog(context, 'Failed to add payment!');
      }
    }
  }

  Future<void> _handleDeletePayment() async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Delete payment'),
        content: const Text(
            'This will completely remove this payment for ALL people involved, not just you.'),
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
        showErrorDialog(context, 'Failed to delete payment');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewPayment = widget.expenseId == null;

    return Selector<GroupsProvider, List<Member>>(
      selector: (_, groups) => groups.selectedGroupMembers,
      builder: (_, members, __) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(isNewPayment ? 'New Payment' : 'Payment'),
          trailingActions: <Widget>[
            PlatformButton(
              androidFlat: (_) => MaterialFlatButtonData(
                textColor: Colors.white,
              ),
              child: PlatformText(_isInEditingMode ? 'Save' : 'Edit'),
              onPressed: _isInEditingMode
                  ? isNewPayment ? _handleAddPayment : _handleUpdatePayment
                  : _toggleEditingMode,
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
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixText: 'Amount',
                  hintText: '0.00',
                  enabled: _isInEditingMode,
                  inputFormatters: [
                    MoneyTextInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                CardPicker(
                  prefix: 'From',
                  text: _from?.fullName ?? '',
                  onPressed: _isInEditingMode ? _pickFrom : null,
                ),
                const Divider(height: 1),
                CardPicker(
                  prefix: 'To',
                  text: _to?.fullName ?? '',
                  onPressed: _isInEditingMode ? _pickTo : null,
                ),
                const SizedBox(height: 16),
                CardPicker(
                  prefix: 'Date',
                  text: DateFormat.yMMMd().format(_date),
                  onPressed: _isInEditingMode ? _pickDate : null,
                ),
                const SizedBox(height: 16),
                if (widget.expenseId != null)
                  PlatformButton(
                    androidFlat: (_) => MaterialFlatButtonData(
                      colorBrightness: Brightness.dark,
                    ),
                    child: Text(
                      'Delete payment',
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                    onPressed: _handleDeletePayment,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
