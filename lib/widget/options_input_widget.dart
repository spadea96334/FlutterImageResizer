import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptionInputWidget extends StatelessWidget {
  OptionInputWidget({
    super.key,
    required this.title,
    this.unitLabel,
    this.onChanged,
    this.allowPattern,
    this.initValue,
    this.icon,
    this.textFieldWidth = 100,
    this.iconButtonOnPressed,
    this.hintText,
  });

  final String title;
  final String? unitLabel;
  final String? initValue;
  final String? hintText;
  final Function(String value)? onChanged;
  final Pattern? allowPattern;
  final Icon? icon;
  final TextEditingController _textEditingController = TextEditingController();
  final double textFieldWidth;
  final Function()? iconButtonOnPressed;
  String get text => getTextFieldValue();

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> inputFormatters = [];

    if (allowPattern != null) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp('[0-9]+')));
    }

    TextField textField = TextField(
        controller: _textEditingController,
        decoration:
            InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 6), hintText: hintText),
        inputFormatters: inputFormatters,
        onChanged: onChanged);

    if (initValue != null) {
      _textEditingController.text = initValue!;
    }

    IconButton? iconButton;
    if (icon != null) {
      iconButton = IconButton(
          onPressed: iconButtonOnPressed,
          icon: icon!,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent);
    }

    return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(children: [
          const SizedBox(width: 10),
          Text('$title :'),
          const SizedBox(width: 5),
          SizedBox(width: textFieldWidth, child: textField),
          const SizedBox(width: 2),
          Text(unitLabel ?? ''),
          iconButton ?? const SizedBox()
        ]));
  }

  String getTextFieldValue() {
    return _textEditingController.text;
  }
}
