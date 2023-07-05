import 'package:flutter/material.dart';
import '../resizer/image_resizer.dart';

class ProgressDialog extends Dialog {
  ProgressDialog(BuildContext context, ImageResizer imageResizer, {super.key})
      : super(
            child: Container(
          width: 500,
          padding: const EdgeInsets.all(8),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListenableBuilder(
                  listenable: imageResizer,
                  builder: (context, child) {
                    double progress = imageResizer.processCount / imageResizer.fileList.length;
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
                            Text('${imageResizer.processCount} / ${imageResizer.fileList.length}'),
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
                  })),
        ));
}
