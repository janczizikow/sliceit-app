import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme.dart';
import '../providers/groups.dart';
import '../screens/group.dart';
import '../screens/settings.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _showGroups = false;

  void _toggleShowGroups() {
    setState(() {
      _showGroups = !_showGroups;
    });
  }

  List<Widget> _renderItems() {
    return [
      ListTile(
        leading: Icon(Icons.group),
        title: Text('New Group'),
        onTap: _openNewGroup,
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Settings'),
        onTap: _openSettings,
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
      )
    ].toList();
  }

  void _openNewGroup() {
    Navigator.of(context).popAndPushNamed(GroupScreen.routeName);
  }

  void _openSettings() {
    Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
  }

  void _dismissDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupsProvider>(context);
    final groups = provider.groups;
    final selectedGroup = provider.selectedGroup;
    final selectGroup = provider.selectGroup;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            otherAccountsPictures: <Widget>[
              Consumer<ThemeProvider>(
                builder: (_, theme, __) => IconButton(
                  icon: Icon(
                    theme.isLight ? Icons.brightness_4 : Icons.brightness_5,
                    color: Colors.white,
                  ),
                  onPressed: theme.toggleTheme,
                ),
              ),
            ],
            accountName: Text('Group'),
            accountEmail: Text(selectedGroup.name),
            onDetailsPressed: _toggleShowGroups,
          ),
          ..._showGroups
              ? groups.map((group) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                    title: Text(group.name),
                    onTap: () {
                      _dismissDrawer();
                      selectGroup(group.id);
                    },
                  );
                })
              : _renderItems(),
        ],
      ),
    );
  }
}
