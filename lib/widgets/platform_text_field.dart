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
  final String placeholder;
  final InputDecoration decoration;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onSubmitted;

  PlatformTextField({
    Key key,
    this.keyboardType,
    this.textInputAction,
    this.keyboardAppearance,
    this.placeholder,
    this.decoration,
    this.controller,
    this.focusNode,
    this.onEditingComplete,
    this.onSubmitted,
    this.autocorrect = true,
    this.autofocus = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  CupertinoTextField buildCupertinoWidget(BuildContext context) {
    return CupertinoTextField(
      placeholder: placeholder,
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
      onEditingComplete: onEditingComplete,
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
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
    );
  }
}
