import 'package:flutter/material.dart';

import './platform_button.dart';

class BalanceList extends StatelessWidget {
  final _groupMembers = [0];

  Widget _renderItem(BuildContext context, int i) {
    final ThemeData theme = Theme.of(context);
    // itemCount is incremented by 1
    bool isLast = _groupMembers.length == i;

    if (isLast) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            child: PlatformButton(
              materialStyle: MaterialButtonStyle.flat,
              child: Text('+ Invite more friends'),
              onPressed: () => {},
            ),
          ),
        ],
      );
    } else {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.accentColor,
        ),
        title: Text('Jan'),
        trailing: Text(
          '\$18.00',
          style: theme.textTheme.body2.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: _groupMembers.length + 1,
      itemBuilder: _renderItem,
    );
  }
}
