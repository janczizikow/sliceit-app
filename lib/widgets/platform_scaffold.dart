import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliceit/widgets/platform_base.dart';

import './platform_appbar.dart';

class PlatformScaffold extends PlatformBase<CupertinoPageScaffold, Scaffold> {
  final PlatformAppBar appBar;
  final Widget body;
  final Color backgroundColor;

  PlatformScaffold({
    Key key,
    this.appBar,
    this.body,
    this.backgroundColor,
  });

  @override
  CupertinoPageScaffold buildCupertinoWidget(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: appBar?.buildCupertinoWidget(context),
      child: body,
    );
  }

  @override
  Scaffold buildMaterialWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar?.buildMaterialWidget(context),
      body: body,
    );
  }
}
