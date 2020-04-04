import 'package:flutter/material.dart';
import 'package:sliceit/widgets/platform_appbar.dart';

import '../widgets/platform_scaffold.dart';
import '../widgets/platform_appbar.dart';
import '../utils/currencies.dart';

class CurrenciesScreen extends StatelessWidget {
  final List<Currency> _currencies =
      currencies.entries.map((entry) => Currency.fromMap(entry.value)).toList();

  Widget _renderItem(BuildContext context, int i) {
    final currency = _currencies[i];
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).textTheme.body2.color,
            child: Text(
              currency.code,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(currency.name),
          onTap: () => Navigator.of(context).pop({'code': currency.code}),
        ),
        Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
          // TODO: add Search!
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.search),
          //     onPressed: () {
          //       showSearch(
          //         context: context,
          //         delegate: SearchDelegate(searchFieldLabel: 'Currency'),
          //       );
          //     },
          //   ),
          // ],
          ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: _currencies.length,
          itemBuilder: _renderItem,
        ),
      ),
    );
  }
}
