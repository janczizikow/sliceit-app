import 'package:flutter/material.dart';

class EmptyExpenses extends StatelessWidget {
  static const double AVATAR_RADIUS = 24;
  final appBar = AppBar();
  final tabBar = TabBar(tabs: []);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    return Container(
      height: mediaQuery.size.height -
          appBar.preferredSize.height -
          tabBar.preferredSize.height -
          statusBarHeight -
          AVATAR_RADIUS -
          16 -
          4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: AVATAR_RADIUS,
            child: Container(
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_basket,
                size: AVATAR_RADIUS,
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
            width: mediaQuery.size.width * 0.50,
            child: Text(
              'Add an expense by pressing the button below',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
