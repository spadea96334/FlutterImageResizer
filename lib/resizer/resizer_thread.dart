import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart';
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
    Image? image = decodeImage(file.readAsBytesSync());
    if (image == null) {
      return false;
    }

    Image resizedImage = copyResize(image, height: config.height, width: config.width, interpolation: config.filter);
    Uint8List? encodedImage;
    switch (config.imageFormat) {
      case ImageFormat.origin:
        encodedImage = encodeNamedImage(file.path, resizedImage);
        break;
      case ImageFormat.jpg:
        encodedImage = encodeJpg(image);
        break;
      case ImageFormat.png:
        encodedImage = encodePng(image);
        break;
      case ImageFormat.bmp:
        encodedImage = encodeBmp(image);
        break;
      default:
        assert(false);
    }

    if (encodedImage == null) {
      return false;
    }

    String filename = p.basename(file.path);
    String baseName = p.basenameWithoutExtension(file.path);
    String newPath = '';
    if (config.imageFormat == ImageFormat.origin) {
      newPath = p.join('/Users/ken/Documents/test', filename);
    } else {
      newPath = p.join('/Users/ken/Documents/test', baseName, '.', config.imageFormat.extension);
    }

    File newFile = File(newPath);
    if (!newFile.existsSync()) {
      newFile.createSync(recursive: true);
    }

    newFile.writeAsBytesSync(encodedImage.toList());
    return true;
  }
}
