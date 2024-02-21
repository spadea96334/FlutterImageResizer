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

enum SizeUnit {
  pixel(0),
  scale(1);

  const SizeUnit(this.value);
  final int value;
}

enum FileTarget { origin, create, move }

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
  SizeUnit unit = SizeUnit.pixel;
  int height = 0;
  int width = 0;
  ImageFormat imageFormat = ImageFormat.origin;
  Interpolation filter = Interpolation.area;
  int jpgQuality = 95;
  int pngCompression = 1;
  ResizePolicy policy = ResizePolicy.always;
  FileTarget target = FileTarget.create;
  bool widthAuto = false;
  bool heightAuto = false;

  ImageResizeConfig() {
    destination = SettingManager().documentsPath;
  }

  ImageResizeConfig copy() {
    ImageResizeConfig config = ImageResizeConfig()
      ..name = name
      ..destination = destination
      ..unit = unit
      ..height = height
      ..width = width
      ..imageFormat = imageFormat
      ..filter = filter
      ..jpgQuality = jpgQuality
      ..pngCompression = pngCompression
      ..policy = policy
      ..target = target
      ..widthAuto = widthAuto
      ..heightAuto = heightAuto;

    return config;
  }

  Pointer<ImageResizeConfigC> toNativeStruct(String file, String dst) {
    Pointer<ImageResizeConfigC> struct = calloc<ImageResizeConfigC>();

    struct.ref.unit = unit.value;
    struct.ref.height = height;
    struct.ref.width = width;
    struct.ref.filter = filter.value;
    struct.ref.jpgQuality = jpgQuality;
    struct.ref.pngCompression = pngCompression;
    struct.ref.file = file.toNativeUtf16();
    struct.ref.dst = dst.toNativeUtf16();
    struct.ref.policy = policy.value;

    return struct;
  }

  factory ImageResizeConfig.fromJson(Map<String, dynamic> json) => _$ImageResizeConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ImageResizeConfigToJson(this);
}

class ImageResizeConfigC extends Struct {
  external Pointer<Utf16> file;
  external Pointer<Utf16> dst;
  @Int()
  external int unit;
  @Int()
  external int width;
  @Int()
  external int height;
  @Int()
  external int filter;
  @Int()
  external int jpgQuality;
  @Int()
  external int pngCompression;
  @Int()
  external int policy;
}
