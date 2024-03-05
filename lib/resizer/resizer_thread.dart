import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:image_resizer/native_bridge.dart';
import 'package:path/path.dart' as p;

import '../model/image_resize_config.dart';

class ResizerThread {
  static ImageResizeConfig config = ImageResizeConfig();

  bool initFailed = false;

  Isolate? _isolate;
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPort;
  Completer<bool>? _completer;

  ResizerThread();

  Future<void> init() async {
    // Because isolate memery is indepedent, must copy config when init.
    _isolate = await Isolate.spawn(initIsolate, [_receivePort.sendPort, config]);
    Completer initCompleter = Completer();
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else if (message == 'initFailed') {
        initFailed = true;
      } else if (message == 'initEnd') {
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

  static void initIsolate(List args) {
    assert(args[0] is SendPort);
    assert(args[1] is ImageResizeConfig);
    SendPort sendPort = args[0];
    config = args[1];

    initCommunication(sendPort, config);

    if (!NativeBridge().isInit) {
      sendPort.send('initFailed');
    }

    sendPort.send('initEnd');
  }

  static void initCommunication(SendPort sendPort, ImageResizeConfig config) {
    ReceivePort receivePort = ReceivePort();
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
    String dir = p.dirname(file.path);
    String baseName = p.basename(file.path);
    String newPath = '';

    if (config.imageFormat != ImageFormat.origin) {
      baseName = p.setExtension(baseName, ".${config.imageFormat.extension}");
    }

    if (config.target == FileTarget.origin) {
      newPath = p.join(dir, baseName);
    } else {
      newPath = p.join(config.destination, baseName);
    }

    var cConfig = config.toNativeStruct(file.path, newPath);
    bool result = NativeBridge().reiszeImage(cConfig);
    calloc.free(cConfig);

    if (!result) {
      return false;
    }

    if (config.target != FileTarget.create && file.path != newPath) {
      await file.delete();
    }

    return true;
  }
}
