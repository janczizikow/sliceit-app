import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import './group.dart';
import './new_expense.dart';
import './new_payment.dart';
import '../models/group.dart';
import '../providers/account.dart';
import '../providers/groups.dart';
import '../widgets/app_drawer.dart';
import '../widgets/balance_list.dart';
import '../widgets/expenses_list.dart';
import '../widgets/speed_dial_label.dart';
import '../widgets/tab_bar_indicator.dart';
import '../widgets/tab_bar_no_ripple.dart';

enum MoreMenuOptions {
  settings,
  export,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _iosTabs = const [
    BottomNavigationBarItem(
      icon: const Icon(CupertinoIcons.home),
    ),
    BottomNavigationBarItem(
      icon: const Icon(CupertinoIcons.shopping_cart),
    )
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<AccountProvider>(context, listen: false).fetchAccount();
  }

  Widget _buildAndroidHome(BuildContext context) {
    return _AndroidHome();
  }

  Widget _tabContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return CupertinoTabView(builder: (context) {
          return BalanceList();
        });
      case 1:
        return CupertinoTabView(builder: (context) {
          return CupertinoPageScaffold(
            child: ExpensesList(),
          );
        });
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      android: _buildAndroidHome,
      ios: (_) => CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: _iosTabs,
        ),
        tabBuilder: _tabContent,
      ),
    );
  }
}

class _AndroidHome extends StatelessWidget {
  final _tabs = <Widget>[
    Tab(
      child: Align(
        alignment: Alignment.center,
        child: const Text('Balance'),
      ),
    ),
    Tab(
      child: Align(
        alignment: Alignment.center,
        child: const Text('Expenses'),
      ),
    ),
  ];
  final _tabsViews = [
    BalanceList(),
    ExpensesList(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Selector<GroupsProvider, Group>(
            selector: (_, groups) => groups.selectedGroup,
            builder: (_, selectedGroup, __) => Text(selectedGroup.name),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            Selector<GroupsProvider, Group>(
              selector: (_, groups) => groups.selectedGroup,
              builder: (_, selectedGroup, __) =>
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
            ),
          ],
          bottom: TabBarNoRipple(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicator: TabBarIndicator(
              color: theme.primaryColorLight.withOpacity(0.3),
            ),
            tabs: _tabs,
          ),
        ),
        body: TabBarView(children: _tabsViews),
        drawer: const AppDrawer(),
        floatingActionButton: SpeedDial(
          tooltip: 'Add Expense or Payment',
          child: const Icon(Icons.add),
          visible: true,
          curve: Curves.decelerate,
          overlayOpacity: theme.brightness == Brightness.dark ? 0.54 : 0.8,
          overlayColor:
              theme.brightness == Brightness.dark ? Colors.black : Colors.white,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.shopping_basket),
              onTap: () {
                Navigator.of(context).pushNamed(
                  NewExpenseScreen.routeName,
                );
              },
              labelWidget: const SpeedDialLabel(
                title: 'New Expense',
                subTitle: 'A purchase made for the group',
              ),
            ),
            SpeedDialChild(
              child: const Icon(Icons.account_balance_wallet),
              onTap: () {
                Navigator.of(context).pushNamed(
                  NewPaymentScreen.routeName,
                );
              },
              labelWidget: const SpeedDialLabel(
                title: 'New Payment',
                subTitle: 'Record a payment made in the group',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
