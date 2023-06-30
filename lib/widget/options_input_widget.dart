import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptionInputWidget extends StatelessWidget {
  const OptionInputWidget({
    super.key,
    required this.title,
    this.unitLabel,
    required this.onChanged,
    this.allowPattern,
    this.initValue,
  });

  final String title;
  final String? unitLabel;
  final String? initValue;
  final Function(String value)? onChanged;
  final Pattern? allowPattern;

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> inputFormatters = [];

    if (allowPattern != null) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp('[0-9]+')));
    }

    TextEditingController textEditingController = TextEditingController();

    TextField textField = TextField(
        controller: textEditingController,
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 6)),
        inputFormatters: inputFormatters,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        });

    if (initValue != null) {
      textEditingController.text = initValue!;
    }

    return Row(children: [
      const SizedBox(width: 10),
      Text('$title :'),
      const SizedBox(width: 5),
      SizedBox(width: 100, child: textField),
      const SizedBox(width: 2),
      Text(unitLabel ?? '')
    ]);
  }
}
