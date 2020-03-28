import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './platform_base.dart';

class PlatformTextField extends PlatformBase<CupertinoTextField, TextField> {
  final bool autofocus;
  final bool autocorrect;
  final bool obscureText;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;

  final InputDecoration decoration;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  PlatformTextField({
    Key key,
    this.keyboardType,
    this.textInputAction,
    this.keyboardAppearance,
    this.decoration,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.autocorrect = true,
    this.autofocus = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  CupertinoTextField buildCupertinoWidget(BuildContext context) {
    return CupertinoTextField(
      autofocus: autofocus,
      autocorrect: autocorrect,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      keyboardAppearance: keyboardAppearance,
      // decoration: decoration, ??
      obscureText: obscureText,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    );
  }

  @override
  TextField buildMaterialWidget(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      autocorrect: autocorrect,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      keyboardAppearance: keyboardAppearance,
      decoration: decoration,
      obscureText: obscureText,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    );
  }
}
