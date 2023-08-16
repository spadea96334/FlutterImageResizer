import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class OptionInputWidget extends HookWidget {
  OptionInputWidget(
      {super.key,
      required this.title,
      this.unitLabel,
      this.onChanged,
      this.allowPattern,
      this.icon,
      this.textFieldWidth = 100,
      this.iconButtonOnPressed,
      this.hintText,
      required this.listenable,
      required this.valueHandler,
      this.ignoreZero = true,
      this.enabled = true});

  final String title;
  final String? unitLabel;
  final String? hintText;
  final Function(String value)? onChanged;
  final Pattern? allowPattern;
  final Icon? icon;
  final TextEditingController _textEditingController = TextEditingController();
  final double textFieldWidth;
  final Function()? iconButtonOnPressed;
  final Listenable listenable;
  final String Function() valueHandler;
  final bool ignoreZero;
  final bool enabled;
  bool _runBuild = false;
  String get text => getTextFieldValue();

  @override
  Widget build(BuildContext context) {
    useListenableSelector(listenable, () => valueChanged());

    List<TextInputFormatter> inputFormatters = [];

    _textEditingController.text = valueHandler();

    if (allowPattern != null) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp('[0-9]+')));
    }

    Widget textField = Theme(
        data: ThemeData(disabledColor: Colors.grey),
        child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
                isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 6), hintText: hintText),
            inputFormatters: inputFormatters,
            enabled: enabled,
            onChanged: (value) {
              if (value.startsWith('0')) {
                if (ignoreZero) {
                  value = value.replaceFirst('0', '');
                  _textEditingController.text = value;
                  _textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: value.length));
                }
              }

              if (onChanged != null) {
                onChanged!(value);
              }
            }));

    IconButton? iconButton;
    if (icon != null) {
      iconButton = IconButton(
          onPressed: iconButtonOnPressed,
          icon: icon!,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent);
    }

    _runBuild = true;

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

  void valueChanged() {
    String value = valueHandler();
    if (!_runBuild) {
      return;
    }
    if (_textEditingController.text == value) {
      return;
    }

    print(title);
    _textEditingController.text = value;
  }
}
