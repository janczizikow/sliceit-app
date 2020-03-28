import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

class PlatformDialogAction
    extends PlatformBase<CupertinoDialogAction, MaterialButton> {
  final Widget child;
  final VoidCallback onPressed;

  PlatformDialogAction({
    @required this.child,
    @required this.onPressed,
  });

  @override
  CupertinoDialogAction buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  MaterialButton buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
}
