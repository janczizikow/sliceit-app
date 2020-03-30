import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

class PlatformAppBar extends PlatformBase<CupertinoNavigationBar, AppBar> {
  final Widget title;
  final Color backgroundColor;
  // iOS
  final Widget trailing;
  final Widget leading;
  // Android
  final double elevation;
  final bool androidCenterTitle;
  final List<Widget> actions;
  final PreferredSizeWidget androidBottom;

  PlatformAppBar({
    this.title,
    this.backgroundColor,
    this.trailing,
    this.leading,
    this.elevation,
    this.androidCenterTitle,
    this.actions,
    this.androidBottom,
  });

  @override
  CupertinoNavigationBar buildCupertinoWidget(BuildContext context) {
    return CupertinoNavigationBar(
      leading: leading,
      middle: title,
      trailing: trailing,
      backgroundColor: backgroundColor,
    );
  }

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar(
      title: title,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: androidCenterTitle,
      bottom: androidBottom,
      actions: actions,
    );
  }
}
