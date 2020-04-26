import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:sliceit/providers/theme.dart';
import 'package:sliceit/screens/edit_group.dart';
import 'package:sliceit/screens/settings.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key key}) : super(key: key);

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

  Future<void> _requestReview() async {
    await AppReview.requestReview;
  }

  List<Widget> _renderItems() {
    return [
      ListTile(
        leading: const Icon(Icons.group),
        title: const Text('New Group'),
        onTap: _openNewGroup,
      ),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: _openSettings,
      ),
      ListTile(
        onTap: _requestReview,
        leading: const Icon(Icons.comment),
        title: const Text('Rate Sliceit'),
      ),
    ].toList();
  }

  void _openNewGroup() {
    Navigator.of(context).popAndPushNamed(EditGroupScreen.routeName);
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
            accountName: const Text('Group'),
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
