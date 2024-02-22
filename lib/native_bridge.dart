import 'dart:ffi';
import 'dart:io';
import 'model/image_resize_config.dart';

typedef ResizeImageNative = Bool Function(Pointer<ImageResizeConfigC>);
typedef ResizeImageDart = bool Function(Pointer<ImageResizeConfigC>);

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
  }

  factory OpenCVBridge() {
    return _singleton;
  }

  bool reiszeImage(Pointer<ImageResizeConfigC> config) {
    return _resizeImageDart(config);
  }
}
