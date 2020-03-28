import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';
import './platform_dialog_action.dart';

Future<T> showPlatformDialog<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  bool androidBarrierDismissible = true,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: builder,
    );
  } else {
    return showDialog(
      context: context,
      builder: builder,
      barrierDismissible: androidBarrierDismissible,
    );
  }
}

class PlatformAlertDialog
    extends PlatformBase<CupertinoAlertDialog, AlertDialog> {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  PlatformAlertDialog({
    Key key,
    @required this.title,
    @required this.message,
    this.cancelText,
    this.confirmText = 'OK',
  }) : super(key: key);

  @override
  CupertinoAlertDialog buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: _actions(context),
    );
  }

  @override
  AlertDialog buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: _actions(context),
    );
  }

  List<Widget> _actions(BuildContext context) {
    var actions = <Widget>[];
    if (cancelText != null) {
      actions.add(
        PlatformDialogAction(
          child: Text(cancelText),
          onPressed: () => _dismiss(context, false),
        ),
      );
    }

    actions.add(
      PlatformDialogAction(
        child: Text(confirmText),
        onPressed: () => _dismiss(context, true),
      ),
    );
    return actions;
  }

  void _dismiss(BuildContext context, bool result) {
    Navigator.of(context, rootNavigator: true).pop(result);
  }
}
