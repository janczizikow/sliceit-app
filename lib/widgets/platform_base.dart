import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class PlatformBase<I extends Widget, A extends Widget>
    extends StatelessWidget {
  PlatformBase({Key key}) : super(key: key);

  I buildCupertinoWidget(BuildContext context);

  A buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    } else {
      return buildMaterialWidget(context);
    }
  }
}
