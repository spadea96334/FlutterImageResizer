import 'dart:ffi';

import 'model/image_resize_config.dart';

typedef ResizeImageNative = Bool Function(Pointer<ImageResizeConfigC>);
typedef ResizeImageDart = bool Function(Pointer<ImageResizeConfigC>);

class OpenCVBridge {
  static final OpenCVBridge _singleton = OpenCVBridge._private();

  late ResizeImageDart _resizeImageDart;

  OpenCVBridge._private() {
    var lib = DynamicLibrary.process();
    _resizeImageDart = lib.lookupFunction<ResizeImageNative, ResizeImageDart>('resizeImage');
  }

  factory OpenCVBridge() {
    return _singleton;
  }

  bool reiszeImage(Pointer<ImageResizeConfigC> config) {
    return _resizeImageDart(config);
  }
}
