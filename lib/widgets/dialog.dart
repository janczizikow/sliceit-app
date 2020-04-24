import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sliceit/widgets/loading_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String message) async {
  showPlatformDialog(
    context: context,
    builder: (context) => PlatformAlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: <Widget>[
        PlatformDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        )
      ],
    ),
  );
}

Future<void> showLoadingDialog(BuildContext context) async {
  showPlatformDialog(
    androidBarrierDismissible: false,
    context: context,
    builder: (context) => LoadingDialog(),
  );
}
