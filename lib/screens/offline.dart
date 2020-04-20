import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/providers/groups.dart';
import 'package:tuple/tuple.dart';

class OfflineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "You're offline",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your internet connection and try again',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Selector<GroupsProvider, Tuple2<Status, Function>>(
                    selector: (_, groups) =>
                        Tuple2(groups.status, groups.fetchGroups),
                    builder: (_, data, __) => PlatformButton(
                      color: Theme.of(context).primaryColor,
                      android: (_) => MaterialRaisedButtonData(
                        colorBrightness: Brightness.dark,
                      ),
                      child: const Text('Try again'),
                      onPressed:
                          data.item1 == Status.PENDING ? null : data.item2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
