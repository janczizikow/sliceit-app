import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

class PlatformActivityIndicator extends PlatformBase<CupertinoActivityIndicator,
    CircularProgressIndicator> {
  @override
  CupertinoActivityIndicator buildCupertinoWidget(BuildContext context) {
    return CupertinoActivityIndicator();
  }

  @override
  CircularProgressIndicator buildMaterialWidget(BuildContext context) {
    return CircularProgressIndicator();
  }
}
