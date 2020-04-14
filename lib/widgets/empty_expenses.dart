import 'package:flutter/material.dart';

class EmptyExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          child: Container(
            alignment: Alignment.center,
            child: const Icon(
              Icons.shopping_basket,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No expenses',
          style: Theme.of(context).textTheme.body2.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.50,
          child: Text(
            'Add an expense by pressing the button below',
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
