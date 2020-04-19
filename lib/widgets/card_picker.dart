import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CardPicker extends StatelessWidget {
  final VoidCallback onPressed;
  final String prefix;
  final String text;

  const CardPicker({
    Key key,
    this.prefix,
    this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformButton(
      android: (_) => MaterialRaisedButtonData(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.zero),
        ),
      ),
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(prefix),
          Text(text),
        ],
      ),
    );
  }
}
