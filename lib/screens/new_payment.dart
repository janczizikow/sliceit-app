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
import 'package:sliceit/widgets/card_input.dart';
import 'package:sliceit/widgets/card_picker.dart';

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

  Future<Member> _pickMember(List<Member> members) async {
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

  Future<void> _handleAddPayment() async {
    Group group =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroup;
    if (group != null) {
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
        _showErrorMessage(err.message);
      } catch (e) {
        _showErrorMessage('Failed to add payment!');
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
