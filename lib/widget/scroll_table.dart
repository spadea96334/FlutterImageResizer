import 'package:flutter/material.dart';

class ScrollTable extends StatelessWidget {
  ScrollTable({super.key, required this.children, this.width});
  final ScrollController _scrollController = ScrollController();

  final List<TableRow> children;
  double? width;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(child: SizedBox(width: width, child: Table(children: children)))));
  }
}
