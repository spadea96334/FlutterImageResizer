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
                            constraints: const BoxConstraints(maxHeight: 100),
                            color: Colors.white30,
                            child: ListView.separated(
                                itemCount: _imageResizer.failedFileList.length,
                                separatorBuilder: listViewSeparatorBuilder,
                                itemBuilder: listViewBuilder))
                      ]);
                })));
  }

  Widget listViewSeparatorBuilder(context, index) {
    return const Divider(height: 0, color: Colors.black);
  }

  Widget listViewBuilder(context, index) {
    String path = _imageResizer.failedFileList[index].path;

    return Text('Failed:$path', overflow: TextOverflow.ellipsis);
  }
}
