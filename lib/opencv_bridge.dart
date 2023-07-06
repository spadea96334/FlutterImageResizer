import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef ResizeImageNative = Bool Function(Pointer<Utf8>, Pointer<Utf8>, Int, Int, Double, Double, Int);
typedef ResizeImageDart = bool Function(Pointer<Utf8>, Pointer<Utf8>, int, int, double, double, int);

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

  bool reiszeImage(String path, String dst, int width, int heigth, double scaleX, double scaleY, int interpolation) {
    return _resizeImageDart(path.toNativeUtf8(), dst.toNativeUtf8(), width, heigth, scaleX, scaleY, interpolation);
  }
}
