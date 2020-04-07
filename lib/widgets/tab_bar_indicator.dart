// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Adjusted version of:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/tab_indicator.dart

import 'package:flutter/material.dart';

class TabBarIndicator extends Decoration {
  /// Create a custom style for selected tab indicator.
  ///
  /// The [insets] and [color] arguments must not be null.
  const TabBarIndicator({
    this.insets = const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    this.color = Colors.white,
  })  : assert(color != null),
        assert(insets != null);

  /// The color of the shape drawn inside the selected tab.
  final Color color;

  /// Locates the selected tab's underline relative to the tab's boundary.
  ///
  /// The [TabBar.indicatorSize] property can be used to define the
  /// tab indicator's bounds in terms of its (centered) tab widget with
  /// [TabIndicatorSize.label], or the entire tab with [TabIndicatorSize.tab].
  final EdgeInsetsGeometry insets;

  @override
  Decoration lerpFrom(Decoration a, double t) {
    if (a is TabBarIndicator) {
      return TabBarIndicator(
        color: Color.lerp(a.color, color, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration lerpTo(Decoration b, double t) {
    if (b is TabBarIndicator) {
      return TabBarIndicator(
        color: Color.lerp(color, b.color, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _TabBarIndicatorPainter(this, onChanged);
  }
}

class _TabBarIndicatorPainter extends BoxPainter {
  _TabBarIndicatorPainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  final TabBarIndicator decoration;

  Color get color => decoration.color;
  EdgeInsetsGeometry get insets => decoration.insets;

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return Rect.fromLTWH(
      indicator.left,
      indicator.top,
      indicator.width,
      indicator.height,
    );
  }

  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size;
    final TextDirection textDirection = configuration.textDirection;
    final Rect indicator = _indicatorRectFor(rect, textDirection);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        indicator,
        Radius.circular(200),
      ),
      paint,
    );
  }
}
