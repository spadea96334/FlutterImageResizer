import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:image_resizer/utility/setting_manager.dart';
import 'package:json_annotation/json_annotation.dart';

part 'image_resize_config.g.dart';

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

enum ResizePolicy {
  always(0),
  reduce(1),
  enlarge(2);

  const ResizePolicy(this.value);
  final int value;
}

@JsonSerializable(explicitToJson: true)
class ImageResizeProfiles {
  List<ImageResizeConfig> profiles = [];

  ImageResizeProfiles();

  factory ImageResizeProfiles.fromJson(Map<String, dynamic> json) => _$ImageResizeProfilesFromJson(json);
  Map<String, dynamic> toJson() => _$ImageResizeProfilesToJson(this);
}

@JsonSerializable()
class ImageResizeConfig {
  String name = '';
  String destination = '';
  int height = 0;
  int width = 0;
  ImageFormat imageFormat = ImageFormat.origin;
  Interpolation filter = Interpolation.area;
  int jpgQuality = 95;
  int pngCompression = 1;
  int scaleX = 100;
  int scaleY = 100;
  ResizePolicy policy = ResizePolicy.always;

  ImageResizeConfig() {
    destination = SettingManager().documentsPath;
  }

  ImageResizeConfig copy() {
    ImageResizeConfig config = ImageResizeConfig()
      ..name = name
      ..destination = destination
      ..height = height
      ..width = width
      ..imageFormat = imageFormat
      ..filter = filter
      ..jpgQuality = jpgQuality
      ..pngCompression = pngCompression
      ..scaleX = scaleX
      ..scaleY = scaleY
      ..policy = policy;

    return config;
  }

  Pointer<ImageResizeConfigC> toNativeStruct(String file, String dst) {
    Pointer<ImageResizeConfigC> struct = calloc<ImageResizeConfigC>();
    if (scaleX != 0 || scaleY != 0) {
      struct.ref.height = 0;
      struct.ref.width = 0;
    } else {
      struct.ref.height = height;
      struct.ref.width = width;
    }

    struct.ref.filter = filter.value;
    struct.ref.jpgQuality = jpgQuality;
    struct.ref.pngCompression = pngCompression;
    struct.ref.file = file.toNativeUtf8();
    struct.ref.dst = dst.toNativeUtf8();
    struct.ref.scaleX = scaleX / 100;
    struct.ref.scaleY = scaleY / 100;
    struct.ref.policy = policy.value;

    return struct;
  }

  factory ImageResizeConfig.fromJson(Map<String, dynamic> json) => _$ImageResizeConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ImageResizeConfigToJson(this);
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
  @Int()
  external int policy;
}
