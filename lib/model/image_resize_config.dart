import 'dart:ffi';

import 'package:ffi/ffi.dart';

enum ImageFormat {
  jpg('jpg'),
  png('png'),
  bmp('bmp'),
  origin('');

  const ImageFormat(this.extension);
  final String extension;
}

enum Interpolation {
  nearest(0),
  linear(1),
  cubic(2),
  area(3),
  lanczos4(4),
  linearExact(5),
  nearestExact(6);

  const Interpolation(this.value);
  final int value;
}

class ImageResizeConfig {
  String destination = '';
  int height = 0;
  int width = 0;
  ImageFormat imageFormat = ImageFormat.origin;
  Interpolation filter = Interpolation.area;
  int jpgQuality = 95;
  int pngCompression = 1;

  Pointer<ImageResizeConfigC> toNativeStruct(String file, String dst) {
    Pointer<ImageResizeConfigC> struct = calloc<ImageResizeConfigC>();
    struct.ref.height = height;
    struct.ref.width = width;
    struct.ref.filter = filter.value;
    struct.ref.jpgQuality = jpgQuality;
    struct.ref.pngCompression = pngCompression;
    struct.ref.file = file.toNativeUtf8();
    struct.ref.dst = dst.toNativeUtf8();
    struct.ref.scaleX = 0.9;
    struct.ref.scaleY = 0.9;

    return struct;
  }
}

class ImageResizeConfigC extends Struct {
  external Pointer<Utf8> file;
  external Pointer<Utf8> dst;
  @Int()
  external int width;
  @Int()
  external int height;
  @Double()
  external double scaleX;
  @Double()
  external double scaleY;
  @Int()
  external int filter;
  @Int()
  external int jpgQuality;
  @Int()
  external int pngCompression;
}
