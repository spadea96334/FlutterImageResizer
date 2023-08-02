import 'package:flutter/material.dart';

class OptionDropdownWidget<T> extends StatelessWidget {
  const OptionDropdownWidget(
      {super.key, required this.value, required this.items, this.onChanged, required this.title});

  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final Function(T? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 10),
      Text(title),
      const SizedBox(width: 5),
      DropdownButton<T>(
          value: value,
          items: items,
          dropdownColor: Colors.grey[100],
          focusColor: Colors.grey[100],
          onChanged: onChanged)
    ]);
  }
}
