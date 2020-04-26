import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CupertinoSizedBox extends StatelessWidget {
  /// If non-null, requires the child to have exactly this width.
  final double width;

  /// If non-null, requires the child to have exactly this height.
  final double height;

  const CupertinoSizedBox({Key key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      ios: (_) => SizedBox(height: height, width: width),
    );
  }
}
