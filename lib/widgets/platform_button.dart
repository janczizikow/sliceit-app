import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

enum MaterialButtonStyle {
  raised,
  flat,
  outline,
}

class PlatformButton extends PlatformBase<CupertinoButton, MaterialButton> {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final Brightness colorBrightness;
  final MaterialButtonStyle materialStyle;

  PlatformButton({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.color,
    this.colorBrightness,
    this.materialStyle = MaterialButtonStyle.raised,
  }) : super(key: key);

  @override
  CupertinoButton buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      child: child,
      color: color,
      onPressed: onPressed,
    );
  }

  @override
  MaterialButton buildMaterialWidget(BuildContext context) {
    switch (materialStyle) {
      case MaterialButtonStyle.flat:
        {
          return FlatButton(
            child: child,
            color: color,
            colorBrightness: colorBrightness,
            onPressed: onPressed,
          );
        }
      case MaterialButtonStyle.outline:
        {
          return OutlineButton(
            child: child,
            color: color,
            onPressed: onPressed,
          );
        }
      default:
        {
          return RaisedButton(
            child: child,
            color: color,
            colorBrightness: colorBrightness,
            onPressed: onPressed,
          );
        }
    }
  }
}
