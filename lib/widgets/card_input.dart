import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CardInput extends StatelessWidget {
  final bool autofocus;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<TextInputFormatter> inputFormatters;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onSubmitted;
  final TextInputType keyboardType;
  final String prefixText;
  final String hintText;
  final bool enabled;

  const CardInput({
    Key key,
    this.autofocus,
    this.controller,
    this.focusNode,
    this.inputFormatters,
    this.onEditingComplete,
    this.onSubmitted,
    this.keyboardType,
    this.prefixText,
    this.hintText,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformTextField(
      autofocus: autofocus,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: TextAlign.end,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      enabled: enabled,
      android: (context) => MaterialTextFieldData(
        decoration: InputDecoration(
          fillColor: Theme.of(context).cardColor,
          filled: true,
          prefixIcon: SizedBox(
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  prefixText,
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
          ),
          hintText: hintText,
          prefixStyle: Theme.of(context).textTheme.bodyText1,
          contentPadding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
