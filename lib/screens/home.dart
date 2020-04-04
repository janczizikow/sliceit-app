import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import './group.dart';
import './settings.dart';
import '../providers/theme.dart';
import '../providers/groups.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/balance_list.dart';
import '../widgets/expenses_list.dart';
import '../widgets/speed_dial_label.dart';

enum MoreMenuOptions {
  settings,
  export,
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final groups = Provider.of<GroupsProvider>(context).groups;
    final selectedGroup = Provider.of<GroupsProvider>(context).selectedGroup;
    // TODO: Create no splash tab bar component
    // https://stackoverflow.com/questions/50020523/how-to-disable-default-widget-splash-effect-in-flutter/58673392#58673392
    return Theme(
      data: Provider.of<ThemeProvider>(context).currentTheme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
      child: DefaultTabController(
        length: 2,
        child: PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(selectedGroup.name),
            elevation: 0,
            androidCenterTitle: true,
            actions: [
              PopupMenuButton<MoreMenuOptions>(
                tooltip: 'More',
                onSelected: (MoreMenuOptions result) {
                  switch (result) {
                    case MoreMenuOptions.settings:
                      Navigator.of(context)
                          .pushNamed(GroupScreen.routeName, arguments: {
                        'groupId': selectedGroup.id,
                        'name': selectedGroup.name,
                        'currency': selectedGroup.currency,
                      });
                      break;
                    default:
                      return null;
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MoreMenuOptions>>[
                  const PopupMenuItem<MoreMenuOptions>(
                    value: MoreMenuOptions.settings,
                    child: Text('Group settings'),
                  ),
                  const PopupMenuItem<MoreMenuOptions>(
                    value: MoreMenuOptions.export,
                    enabled: false,
                    child: Text('Export as spreadsheet'),
                  ),
                ],
              ),
            ],
            androidBottom: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              indicatorWeight: 0.0,
              indicator: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 6,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(200),
                color: Theme.of(context).primaryColorLight.withOpacity(0.3),
              ),
              tabs: <Widget>[
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Balance'),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Expenses'),
                  ),
                ),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Consumer<ThemeProvider>(
                  builder: (_, theme, __) => UserAccountsDrawerHeader(
                    otherAccountsPictures: <Widget>[
                      IconButton(
                        icon: Icon(
                          theme.isLight
                              ? Icons.brightness_4
                              : Icons.brightness_5,
                          color: Colors.white,
                        ),
                        onPressed: theme.toggleTheme,
                      )
                    ],
                    accountName: Text('Group'),
                    accountEmail: Text(selectedGroup.name),
                    // TODO: Group selection
                    onDetailsPressed: groups.length > 1 ? () {} : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.group),
                  title: Text('New Group'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(GroupScreen.routeName);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.of(context)
                        .popAndPushNamed(SettingsScreen.routeName);
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('App information'),
                ),
                ListTile(
                  onTap: () => {},
                  leading: Icon(Icons.comment),
                  title: Text('Rate Sliceit'),
                ),
                ListTile(
                  onTap: () => {},
                  leading: Icon(Icons.help),
                  title: Text('Support'),
                ),
                ListTile(
                  onTap: () => {},
                  leading: Icon(Icons.info),
                  title: Text('Acknowledgements'),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              BalanceList(),
              ExpensesList(),
            ],
          ),
          floatingActionButton: SpeedDial(
            tooltip: 'Add Expense or Payment',
            child: Icon(Icons.add),
            visible: true,
            curve: Curves.decelerate,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.shopping_basket),
                onTap: () {},
                labelWidget: SpeedDialLabel(
                  title: 'New Expense',
                  subTitle: 'A purchase made for the group',
                ),
              ),
              SpeedDialChild(
                child: const Icon(Icons.account_balance_wallet),
                onTap: () => {},
                labelWidget: SpeedDialLabel(
                  title: 'New Payment',
                  subTitle: 'Record a payment made in the group',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
