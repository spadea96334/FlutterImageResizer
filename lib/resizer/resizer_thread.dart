import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:image_resizer/opencv_bridge.dart';
import 'package:path/path.dart' as p;

import '../model/image_resize_config.dart';

class ResizerThread {
  static ImageResizeConfig config = ImageResizeConfig();
  Isolate? isolate;
  final ReceivePort receivePort = ReceivePort();
  SendPort? sendPort;
  Completer<bool>? completer;

  ResizerThread();

  Future<void> initIsolate() async {
    isolate = await Isolate.spawn(initCommunication, receivePort.sendPort);
    Completer initCompleter = Completer();
    receivePort.listen((message) {
      if (message is SendPort) {
        sendPort = message;
        initCompleter.complete();
      } else {
        completer?.complete(message);
        completer = null;
      }
    });

    return initCompleter.future;
  }

  Future<bool> resize(File file) async {
    while (isolate == null || sendPort == null || completer != null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    completer = Completer();
    sendPort!.send(file);

    return completer!.future;
  }

  static void initCommunication(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      bool result = await resizeImage(message);
      sendPort.send(result);
    });
  }

  static Future<bool> resizeImage(File file) async {
    String filename = p.basename(file.path);
    String baseName = p.basenameWithoutExtension(file.path);
    String newPath = '';
    if (config.imageFormat == ImageFormat.origin) {
      newPath = p.join('/Users/ken/Documents/test', filename);
    } else {
      newPath = p.join('/Users/ken/Documents/test', baseName, '.', config.imageFormat.extension);
    }

    return OpenCVBridge().reiszeImage(file.path, newPath, config.width, config.height, 0.9, 0.9, config.filter.value);
  }
}
