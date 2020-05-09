import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/models/member.dart';
import 'package:sliceit/providers/expenses.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/services/api.dart';
import 'package:sliceit/utils/currencies.dart';
import 'package:sliceit/widgets/dialog.dart';
import 'package:tuple/tuple.dart';

class SuggestedPaymentsScreenArguments {
  final String groupId;
  const SuggestedPaymentsScreenArguments({this.groupId});
}

class SuggestedPaymentsScreen extends StatefulWidget {
  static const routeName = '/suggested-payments';
  final String groupId;

  const SuggestedPaymentsScreen({
    Key key,
    @required this.groupId,
  })  : assert(groupId != null),
        super(key: key);

  @override
  _SuggestedPaymentsScreenState createState() =>
      _SuggestedPaymentsScreenState();
}

class _SuggestedPaymentsScreenState extends State<SuggestedPaymentsScreen> {
  List<Tuple2<Map<String, dynamic>, bool>> _suggestedPayments = [];
  int _activePaymentsCount = 0;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_getSuggestedPayments);
  }

  void _getSuggestedPayments() {
    GroupsProvider groups = Provider.of<GroupsProvider>(context, listen: false);
    int total = groups.selectedGroup.members
        .fold(0, (acc, member) => acc + member.balance.abs());
    if (total == 0) {
      setState(() {
        _suggestedPayments = [];
      });
    } else {
      List<Member> members = groups
          .byId(widget.groupId)
          .members
          .map((member) => member.copy())
          .toList();
      List<Member> membersByBalanceAscending = members
        ..sort((a, b) => a.balance.compareTo(b.balance));
      int i = 0;
      int j = membersByBalanceAscending.length - 1;
      final List<Tuple2<Map<String, dynamic>, bool>> payments = [];
      var amount = 0;

      while (i < j) {
        amount = min(
          membersByBalanceAscending[i].balance.abs(),
          membersByBalanceAscending[j].balance.abs(),
        );
        membersByBalanceAscending[i].balance += amount;
        membersByBalanceAscending[j].balance -= amount;
        payments.add(
          Tuple2({
            'groupId': widget.groupId,
            'currency': groups.selectedGroup.currency,
            'amount': amount,
            'from': membersByBalanceAscending[i],
            'to': membersByBalanceAscending[j],
            'date': DateTime.now().toIso8601String(),
          }, false),
        );

        if (membersByBalanceAscending[i].balance == 0) {
          i++;
        }
        if (membersByBalanceAscending[j].balance == 0) {
          j--;
        }
      }

      setState(() {
        _suggestedPayments = payments;
      });
    }
  }

  Future<void> _addPayments() async {
    setState(() {
      _isFetching = true;
    });
    try {
      await Provider.of<ExpensesProvider>(context, listen: false)
          .createManyPayments(
        _suggestedPayments.map((payment) => payment.item1).toList(),
      );
      Navigator.of(context).pop();
    } on ApiError catch (err) {
      showErrorDialog(context, err.message);
    } catch (e) {
      print(e);
      showErrorDialog(context, 'Failed to add payments!');
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Suggested payments'),
      ),
      body: SafeArea(
        child: _suggestedPayments.isNotEmpty
            ? ListView.builder(
                itemCount: _suggestedPayments.length + 1,
                itemBuilder: (context, i) {
                  bool isLast = _suggestedPayments.length == i;

                  if (isLast) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: PlatformButton(
                        color: Theme.of(context).primaryColor,
                        android: (_) => MaterialRaisedButtonData(
                          colorBrightness: Brightness.dark,
                        ),
                        child:
                            Text(_isFetching ? 'Loading...' : 'Add payments'),
                        onPressed: (_activePaymentsCount <= 0 || _isFetching)
                            ? null
                            : _addPayments,
                      ),
                    );
                  }
                  var payment = _suggestedPayments[i].item1;
                  return Card(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          if (!_suggestedPayments[i].item2) {
                            _activePaymentsCount++;
                          } else {
                            _activePaymentsCount--;
                          }
                          _suggestedPayments[i] =
                              Tuple2(payment, !_suggestedPayments[i].item2);
                        });
                      },
                      leading: Checkbox(
                        value: _suggestedPayments[i].item2,
                        onChanged: (bool value) {
                          setState(() {
                            if (value) {
                              _activePaymentsCount++;
                            } else {
                              _activePaymentsCount--;
                            }
                            _suggestedPayments[i] = Tuple2(payment, value);
                          });
                        },
                      ),
                      title: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "From ",
                                style: theme.textTheme.bodyText1,
                              ),
                              TextSpan(
                                text: payment['from'].fullName,
                                style: theme.textTheme.bodyText1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "To ",
                              style: theme.textTheme.bodyText1,
                            ),
                            TextSpan(
                              text: payment['to'].fullName,
                              style: theme.textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      trailing: Text(
                        NumberFormat.currency(
                          name: payment['currency'],
                          symbol: currencies[payment['currency']]['symbol'],
                        ).format(payment['amount'] / 100),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  );
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    child: Container(
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.account_balance_wallet,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Payments',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
      ),
    );
  }
}
