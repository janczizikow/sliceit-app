import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

class PlatformAppBar extends PlatformBase<CupertinoNavigationBar, AppBar> {
  final Widget title;

  PlatformAppBar({
    this.title,
  });

  @override
  CupertinoNavigationBar buildCupertinoWidget(BuildContext context) {
    return CupertinoNavigationBar(
      middle: title,
    );
  }

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar(
      title: title,
    );
  }
}
