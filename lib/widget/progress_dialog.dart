import 'package:flutter/material.dart';
import '../resizer/image_resizer.dart';

class ProgressDialog extends StatelessWidget {
  ProgressDialog({super.key});

  final ImageResizer _imageResizer = ImageResizer();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            width: 500,
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
                listenable: _imageResizer.progressNotifier,
                builder: (context, child) {
                  double progress = _imageResizer.processCount / _imageResizer.fileList.length;
                  Text label = progress == 1 ? const Text('Successed!') : const Text('Processing...');

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
                                if (progress != 1) {
                                  return;
                                }

                                Navigator.pop(context);
                              },
                              child: const Text('Close', style: TextStyle(color: Colors.black)))
                        ])
                      ]);
                })));
  }
}
