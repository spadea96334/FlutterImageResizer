import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:image_resizer/opencv_bridge.dart';
import 'package:path/path.dart' as p;

import '../model/image_resize_config.dart';

class ResizerThread {
  static ImageResizeConfig config = ImageResizeConfig();
  Isolate? _isolate;
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  Completer<bool>? _completer;

  ResizerThread();

  Future<void> initIsolate() async {
    // Because isolate memery is indepedent, must copy config when init.
    _isolate = await Isolate.spawn(initCommunication, [_receivePort.sendPort, config]);
    Completer initCompleter = Completer();
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        initCompleter.complete();
      } else {
        _completer?.complete(message);
        _completer = null;
      }
    });

    return initCompleter.future;
  }

  Future<bool> resize(File file) async {
    while (_isolate == null || _sendPort == null || _completer != null) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _completer = Completer();
    _sendPort!.send(file);

    return _completer!.future;
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
