import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/account.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Consumer<AccountProvider>(
      builder: (_, data, __) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Notifications'),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: PlatformText(
                'Groups',
                style: theme.textTheme.subtitle,
              ),
            ),
            SwitchListTile(
              title: const Text('When someone adds me to a group'),
              value: data.notifyWhenAddedToGroup,
              onChanged: (bool value) async {
                await data.updateNotificationSettings(
                    notifyWhenAddedToGroup: value);
              },
            ),
            ListTile(
              title: PlatformText(
                'Expenses',
                style: theme.textTheme.subtitle,
              ),
            ),
            SwitchListTile(
              title: const Text('When an expense is added'),
              value: data.notifyWhenExpenseAdded,
              onChanged: (bool value) async {
                await data.updateNotificationSettings(
                    notifyWhenExpenseAdded: value);
              },
            ),
            SwitchListTile(
              title: const Text('When an expense is edited/deleted'),
              value: data.notifyWhenExpenseUpdated,
              onChanged: (bool value) async {
                await data.updateNotificationSettings(
                    notifyWhenExpenseUpdated: value);
              },
            ),
            ListTile(
              title: PlatformText(
                'Payments',
                style: theme.textTheme.subtitle,
              ),
            ),
            SwitchListTile(
              title: const Text('When a payment is added'),
              value: data.notifyWhenPaymentAdded,
              onChanged: (bool value) async {
                await data.updateNotificationSettings(
                    notifyWhenPaymentAdded: value);
              },
            ),
            SwitchListTile(
              title: const Text('When a payment is edited/delted'),
              value: data.notifyWhenPaymentUpdated,
              onChanged: (bool value) async {
                await data.updateNotificationSettings(
                    notifyWhenPaymentUpdated: value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
