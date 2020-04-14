import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import './empty_expenses.dart';
import '../models/expense.dart';

class ExpensesList extends StatelessWidget {
  final List<Expense> _expenses = [
    Expense(
      id: '1',
      name: 'Groceries',
      payerId: '1',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      currency: 'EUR',
      amount: 10.00,
    )
  ];

  Widget _renderItem(BuildContext context, int i) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            child: Icon(
              _expenses[i].isPayment
                  ? Icons.account_balance_wallet
                  : Icons.shopping_basket,
            ),
          ),
          title: Text(_expenses[i].name),
          subtitle: Text('Jan'), // TODO: display dynamically payers name
          trailing: Text(
            '\$${_expenses[i].amount}',
            style: Theme.of(context).textTheme.body2.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: _expenses.isEmpty
          ? EmptyExpenses()
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: _expenses.length,
              itemBuilder: _renderItem,
            ),
    );
  }
}
