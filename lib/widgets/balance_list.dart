import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';

import '../providers/groups.dart';
import '../models/group.dart';
import '../screens/group.dart';
import '../models/member.dart';
import '../screens/group_invites.dart';
import './avatar.dart';
import '../utils/currencies.dart';

class BalanceList extends StatelessWidget {
  Future<void> _fetchGroup(BuildContext context, String id) async {
    await Provider.of<GroupsProvider>(context, listen: false).fetchGroup(id);
  }

  Widget _buildIos(BuildContext context) {
    return Selector<GroupsProvider, Tuple3<String, List<Member>, String>>(
      selector: (_, groups) => Tuple3(
        groups.selectedGroupId,
        groups.selectedGroupMembers,
        groups.selectedGroup.currency,
      ),
      builder: (_, data, __) => CupertinoPageScaffold(
        child: CustomScrollView(
          semanticChildCount: 6,
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              // automaticallyImplyLeading: false,
              leading: Align(
                widthFactor: 1.0,
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Groups'),
                  onPressed: () {},
                ),
              ),
              largeTitle: Selector<GroupsProvider, Group>(
                selector: (_, groups) => groups.selectedGroup,
                builder: (_, selectedGroup, __) => Text(
                  selectedGroup.name,
                  maxLines: 1,
                ),
              ),
              trailing: Selector<GroupsProvider, Group>(
                selector: (_, groups) => groups.selectedGroup,
                builder: (_, selectedGroup, __) => Align(
                  widthFactor: 1.0,
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Edit'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushNamed(GroupScreen.routeName, arguments: {
                        'groupId': selectedGroup.id,
                        'name': selectedGroup.name,
                        'currency': selectedGroup.currency,
                      });
                    },
                  ),
                ),
              ),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () => _fetchGroup(context, data.item1),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
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
                              onPressed: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pushNamed(
                                GroupInvitesScreen.routeName,
                                arguments: data.item1,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Avatar(
                              radius: 24,
                              initals: data.item2[i].initials,
                              avatar: data.item2[i].avatar,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(data.item2[i].fullName),
                                ],
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                name: data.item3,
                                symbol: currencies[data.item3]['symbol'],
                              ).format(data.item2[i].balance / 100),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  childCount: data.item2.length + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Selector<GroupsProvider, Tuple3<String, List<Member>, String>>(
      selector: (_, groups) => Tuple3(
        groups.selectedGroupId,
        groups.selectedGroupMembers,
        groups.selectedGroup.currency,
      ),
      builder: (_, data, __) => RefreshIndicator(
        onRefresh: () => _fetchGroup(context, data.item1),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                  ).format(data.item2[i].balance / 100),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      ios: _buildIos,
      android: _buildAndroid,
    );
  }
}
