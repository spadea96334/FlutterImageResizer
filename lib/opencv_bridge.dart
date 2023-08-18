import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'model/image_resize_config.dart';

typedef ResizeImageNative = Bool Function(Pointer<ImageResizeConfigC>);
typedef ResizeImageDart = bool Function(Pointer<ImageResizeConfigC>);
typedef FlutterPrintFunctionDef = Void Function(Pointer<Utf8> cString);

class OpenCVBridge {
  static final OpenCVBridge _singleton = OpenCVBridge._private();

  late ResizeImageDart _resizeImageDart;

  OpenCVBridge._private() {
    DynamicLibrary? lib;
    if (Platform.isMacOS) {
      lib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      lib = DynamicLibrary.open('native_library.dll');
    }

    // TODO: show tips
    _resizeImageDart = lib!.lookupFunction<ResizeImageNative, ResizeImageDart>('resizeImage');
    if (kDebugMode) {
      initFlutterPrint(lib);
    }
  }

  factory OpenCVBridge() {
    return _singleton;
  }

  bool reiszeImage(Pointer<ImageResizeConfigC> config) {
    return _resizeImageDart(config);
  }

  void initFlutterPrint(DynamicLibrary lib) {
    var pointer = Pointer.fromFunction<FlutterPrintFunctionDef>(flutterPrint);
    var cInitFPrint =
        lib.lookup<NativeFunction<Void Function(Pointer)>>('initFPrint').asFunction<void Function(Pointer)>();
    cInitFPrint(pointer);
  }

  static void flutterPrint(Pointer<Utf8> cString) {
    print(cString.toDartString());
  }
}
