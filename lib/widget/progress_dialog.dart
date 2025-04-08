import 'package:flutter/material.dart';
import 'package:image_resizer/widget/scroll_table.dart';
import '../resizer/image_resizer.dart';

class ProgressDialog extends StatelessWidget {
  ProgressDialog({super.key});

  final ImageResizer _imageResizer = ImageResizer();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
            width: 600,
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
                listenable: _imageResizer.progressNotifier,
                builder: (context, child) {
                  double progress = _imageResizer.processCount / _imageResizer.fileList.length;
                  Text label;
                  if (_imageResizer.initFailed) {
                    label = const Text('Init failed');
                  } else {
                    label = progress == 1 ? const Text('Successed!') : const Text('Processing...');
                  }

                  return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        label,
                        Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: LinearProgressIndicator(value: progress)),
                        Row(children: [
                          Text('${_imageResizer.processCount} / ${_imageResizer.fileList.length}'),
                          const Expanded(child: SizedBox()),
                          TextButton(
                              onPressed: () {
                                if (progress != 1 && !_imageResizer.initFailed) {
                                  return;
                                }

                                Navigator.pop(context);
                              },
                              child: const Text('Close', style: TextStyle(color: Colors.black)))
                        ]),
                        Container(
                            constraints: const BoxConstraints(minHeight: 100, maxHeight: 100),
                            width: 568,
                            color: Colors.white30,
                            child: ScrollTable(width: 568, children: _generateDataRows()))
                      ]);
                })));
  }

  List<TableRow> _generateDataRows() {
    List<TableRow> rows = [];
    double rowSpacing = 20;

    rows.add(TableRow(decoration: BoxDecoration(color: Colors.grey[400]), children: [
      TableCell(child: Row(spacing: rowSpacing, children: [const Text('Status'), const Text('Path')]))
    ]));

    for (var file in _imageResizer.failedFileList) {
      rows.add(TableRow(children: [
        TableCell(child: Row(spacing: rowSpacing, children: [Text('Failed'), Text(file.path)]))
      ]));
    }

    return rows;
  }
}
