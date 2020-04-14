import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';

import '../providers/groups.dart';
import '../models/member.dart';
import '../screens/group_invites.dart';
import './avatar.dart';
import '../utils/currencies.dart';

class BalanceList extends StatelessWidget {
  Future<void> _fetchGroup(BuildContext context, String id) async {
    await Provider.of<GroupsProvider>(context, listen: false).fetchGroup(id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Selector<GroupsProvider, Tuple3<String, List<Member>, String>>(
        selector: (_, groups) => Tuple3(
          groups.selectedGroupId,
          groups.selectedGroupMembers,
          groups.selectedGroup.currency,
        ),
        builder: (_, data, __) => RefreshIndicator(
          onRefresh: () => _fetchGroup(context, data.item1),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: data.item2.length + 1,
            itemBuilder: (_, i) {
              final ThemeData theme = Theme.of(context);
              // itemCount is incremented by 1
              bool isLast = data.item2.length == i;
              if (isLast) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      child: PlatformButton(
                        androidFlat: (_) => MaterialFlatButtonData(),
                        child: const Text('+ Invite more friends'),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          GroupInvitesScreen.routeName,
                          arguments: data.item1,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return ListTile(
                  leading: Avatar(
                    initals: data.item2[i].initials,
                    avatar: data.item2[i].avatar,
                  ),
                  title: Text(data.item2[i].fullName),
                  trailing: Text(
                    NumberFormat.currency(
                      name: data.item3,
                      symbol: currencies[data.item3]['symbol'],
                    ).format(data.item2[i].balance),
                    style: theme.textTheme.body2.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
