import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

class PlatformAppBar extends PlatformBase<CupertinoNavigationBar, AppBar> {
  PlatformAppBar();

  @override
  CupertinoNavigationBar buildCupertinoWidget(BuildContext context) {
    return CupertinoNavigationBar();
  }

  @override
  AppBar buildMaterialWidget(BuildContext context) {
    return AppBar();
  }
}
