import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sliceit/utils/currencies.dart';

class CurrenciesScreen extends StatelessWidget {
  final List<Currency> currencies;

  const CurrenciesScreen(this.currencies, {Key key}) : super(key: key);

  Widget _renderItem(BuildContext context, int i) {
    final currency = currencies[i];
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
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        trailingActions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              Currency result = await showSearch<Currency>(
                context: context,
                delegate: CurrenciesSearchDelegate(currencies),
              );
              if (result != null) {
                Navigator.of(context).pop({'code': result.code});
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: currencies.length,
          itemBuilder: _renderItem,
        ),
      ),
    );
  }
}

class CurrenciesSearchDelegate extends SearchDelegate<Currency> {
  final List<Currency> currencies;
  CurrenciesSearchDelegate(this.currencies);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;
    if (isDarkMode) {
      return theme.copyWith(
        primaryColor: theme.appBarTheme.color,
        primaryIconTheme: theme.primaryIconTheme,
        primaryColorBrightness: Brightness.dark,
        textTheme: theme.textTheme.copyWith(
          title: TextStyle(fontWeight: FontWeight.normal),
        ),
      );
    } else {
      return super.appBarTheme(context);
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: BackButtonIcon(),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Currency> results = query.isEmpty
        ? currencies
        : currencies
            .where(
              (currency) => currency.name.toLowerCase().startsWith(
                    query.toLowerCase(),
                  ),
            )
            .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).textTheme.body2.color,
            child: Text(
              results[i].code,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(results[i].name),
          onTap: () => {close(context, results[i])},
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Currency> suggestions = currencies
        .where(
          (currency) => currency.name.toLowerCase().startsWith(
                query.toLowerCase(),
              ),
        )
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).textTheme.body2.color,
            child: Text(
              suggestions[i].code,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(suggestions[i].name),
          onTap: () => {close(context, suggestions[i])},
        );
      },
    );
  }
}
