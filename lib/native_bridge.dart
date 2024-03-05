import 'dart:ffi';
import 'dart:io';
import 'model/image_resize_config.dart';

typedef ResizeImageNative = Bool Function(Pointer<ImageResizeConfigC>);
typedef ResizeImageDart = bool Function(Pointer<ImageResizeConfigC>);

class NativeBridge {
  static final NativeBridge _singleton = NativeBridge._private();

  late ResizeImageDart _resizeImageDart;
  bool isInit = false;

  NativeBridge._private() {
    DynamicLibrary? lib;
    if (Platform.isMacOS) {
      lib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      lib = DynamicLibrary.open('native_library.dll');
    }

    if (lib == null) {
      return;
    }

    _resizeImageDart = lib.lookupFunction<ResizeImageNative, ResizeImageDart>('resizeImage');
    isInit = true;
  }

  factory NativeBridge() {
    return _singleton;
  }

  bool reiszeImage(Pointer<ImageResizeConfigC> config) {
    return _resizeImageDart(config);
  }
}
