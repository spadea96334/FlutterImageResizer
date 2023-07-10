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
    // Because isolate memery is indepedent, must copy config when init.
    isolate = await Isolate.spawn(initCommunication, [receivePort.sendPort, config]);
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

  static void initCommunication(List args) {
    assert(args[0] is SendPort);
    assert(args[1] is ImageResizeConfig);
    ReceivePort receivePort = ReceivePort();
    SendPort sendPort = args[0];
    config = args[1];
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is ImageResizeConfig) {
        config = message;
        return;
      }

      bool result = await resizeImage(message);
      sendPort.send(result);
    });
  }

  static Future<bool> resizeImage(File file) async {
    String filename = p.basename(file.path);
    String baseName = p.basenameWithoutExtension(file.path);
    String newPath = '';
    print('dst: ${config.destination}');
    if (config.imageFormat == ImageFormat.origin) {
      newPath = p.join(config.destination, filename);
    } else {
      newPath = p.join(config.destination, baseName, '.', config.imageFormat.extension);
    }
    print('dst2: $newPath');
    return OpenCVBridge().reiszeImage(config.toNativeStruct(file.path, newPath));
  }
}
