import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sliceit/models/group.dart';

import './group.dart';
import '../providers/theme.dart';
import '../providers/groups.dart';
import '../widgets/platform_appbar.dart';
import '../widgets/platform_scaffold.dart';
import '../widgets/app_drawer.dart';
import '../widgets/balance_list.dart';
import '../widgets/expenses_list.dart';
import '../widgets/speed_dial_label.dart';

enum MoreMenuOptions {
  settings,
  export,
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            title: Selector<GroupsProvider, Group>(
              selector: (_, groups) => groups.selectedGroup,
              builder: (_, selectedGroup, __) => Text(selectedGroup.name),
            ),
            elevation: 0,
            androidCenterTitle: true,
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
          drawer: AppDrawer(),
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
