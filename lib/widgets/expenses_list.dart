import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/models/expense.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/providers/expenses.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/screens/expense.dart';
import 'package:sliceit/screens/payment.dart';
import 'package:sliceit/utils/currencies.dart';
import 'package:sliceit/widgets/empty_expenses.dart';
import 'package:tuple/tuple.dart';

class ExpensesList extends StatefulWidget {
  @override
  _ExpensesListState createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  int _page = 1;
  bool _allFetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchExpenses();
    });
  }

  Future<void> _refreshExpenses() async {
    final String groupId =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroupId;
    if (groupId != null) {
      final List<Expense> expenses =
          await Provider.of<ExpensesProvider>(context, listen: false)
              .fetchExpensesPage(groupId, 1);
      if (mounted) {
        setState(() {
          _page = 2;
          _allFetched = expenses.isEmpty;
        });
      }
    }
  }

  Future<void> _fetchExpenses() async {
    final String groupId =
        Provider.of<GroupsProvider>(context, listen: false).selectedGroupId;
    if (groupId != null) {
      final List<Expense> expenses =
          await Provider.of<ExpensesProvider>(context, listen: false)
              .fetchExpensesPage(groupId, _page);
      if (mounted) {
        setState(() {
          _page += 1;
          _allFetched = expenses.isEmpty;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Selector2<GroupsProvider, ExpensesProvider,
          Tuple2<Status, List<Expense>>>(
        selector: (_, groups, expenses) => Tuple2(
          expenses.status,
          expenses.byGroupId(groups.selectedGroupId),
        ),
        builder: (_, data, __) => PlatformWidget(
          ios: (_) => Container(
            child: const Text('Expenses list'),
          ),
          android: (_) => NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (_allFetched) {
                return false;
              }
              final bool endThresholdReached = scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent * 0.8;
              if (data.item1 != Status.PENDING && endThresholdReached) {
                _fetchExpenses();
              }
              return true;
            },
            child: RefreshIndicator(
              onRefresh: _refreshExpenses,
              child: data.item2.isEmpty
                  ? ListView(
                      children: <Widget>[
                        EmptyExpenses(),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: data.item1 == Status.PENDING
                          ? data.item2.length + 1
                          : data.item2.length,
                      itemBuilder: (BuildContext context, int i) {
                        if (data.item1 == Status.PENDING &&
                            i == data.item2.length) {
                          return Container(
                            height: 48,
                            child: Center(
                              child: PlatformCircularProgressIndicator(),
                            ),
                          );
                        }
                        final expense = data.item2[i];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                if (expense.isPayment) {
                                  Navigator.of(context).pushNamed(
                                    PaymentScreen.routeName,
                                    arguments: PaymentScreenArguments(
                                      expenseId: expense.id,
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).pushNamed(
                                    ExpenseScreen.routeName,
                                    arguments: ExpenseScreenArguments(
                                      expenseId: expense.id,
                                    ),
                                  );
                                }
                              },
                              leading: CircleAvatar(
                                child: Icon(
                                  expense.isPayment
                                      ? Icons.account_balance_wallet
                                      : Icons.shopping_basket,
                                ),
                              ),
                              title: Text(expense.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Selector<GroupsProvider, Function>(
                                    selector: (_, groups) =>
                                        groups.memberFirstName,
                                    builder: (_, getMemberFirstName, __) =>
                                        Text(
                                      getMemberFirstName(expense.payerId),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat.yMMMd().format(expense.date),
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                              trailing: Text(
                                NumberFormat.currency(
                                  name: expense.currency,
                                  symbol: currencies[expense.currency]
                                      ['symbol'],
                                ).format(expense.amount / 100),
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
