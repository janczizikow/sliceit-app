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
import 'package:sliceit/widgets/dialog.dart';

class NewPaymentScreen extends StatefulWidget {
  static const routeName = '/new-payment';

  const NewPaymentScreen({
    Key key,
  }) : super(key: key);

  @override
  _NewPaymentScreenState createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends State<NewPaymentScreen> {
  TextEditingController _amountController;
  Member _from;
  Member _to;
  DateTime _date = new DateTime.now();
  String _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = new TextEditingController();
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
  }

  @override
  dispose() {
    _amountController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Selector<GroupsProvider, List<Member>>(
      selector: (_, groups) => groups.selectedGroupMembers,
      builder: (_, members, __) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('New Payment'),
          trailingActions: <Widget>[
            PlatformButton(
              androidFlat: (_) => MaterialFlatButtonData(
                textColor: Colors.white,
              ),
              child: PlatformText('Save'),
              onPressed: _handleAddPayment,
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixText: 'Amount',
                  hintText: '0.00',
                  inputFormatters: [
                    MoneyTextInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                CardPicker(
                  prefix: 'From',
                  text: _from?.fullName ?? '',
                  onPressed: _pickFrom,
                ),
                const Divider(height: 1),
                CardPicker(
                  prefix: 'To',
                  text: _to?.fullName ?? '',
                  onPressed: _pickTo,
                ),
                const SizedBox(height: 16),
                CardPicker(
                  prefix: 'Date',
                  text: DateFormat.yMMMd().format(_date),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
