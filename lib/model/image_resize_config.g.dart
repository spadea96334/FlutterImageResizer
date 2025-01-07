// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_resize_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageResizeProfiles _$ImageResizeProfilesFromJson(Map<String, dynamic> json) =>
    ImageResizeProfiles()
      ..profiles = (json['profiles'] as List<dynamic>)
          .map((e) => ImageResizeConfig.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ImageResizeProfilesToJson(
        ImageResizeProfiles instance) =>
    <String, dynamic>{
      'profiles': instance.profiles.map((e) => e.toJson()).toList(),
    };

ImageResizeConfig _$ImageResizeConfigFromJson(Map<String, dynamic> json) =>
    ImageResizeConfig()
      ..name = json['name'] as String
      ..destination = json['destination'] as String
      ..unit = $enumDecode(_$SizeUnitEnumMap, json['unit'])
      ..height = (json['height'] as num).toInt()
      ..width = (json['width'] as num).toInt()
      ..imageFormat = $enumDecode(_$ImageFormatEnumMap, json['imageFormat'])
      ..filter = $enumDecode(_$InterpolationEnumMap, json['filter'])
      ..jpgQuality = (json['jpgQuality'] as num).toInt()
      ..pngCompression = (json['pngCompression'] as num).toInt()
      ..policy = $enumDecode(_$ResizePolicyEnumMap, json['policy'])
      ..target = $enumDecode(_$FileTargetEnumMap, json['target'])
      ..widthAuto = json['widthAuto'] as bool
      ..heightAuto = json['heightAuto'] as bool
      ..convertWebpToPng = json['convertWebpToPng'] as bool;

Map<String, dynamic> _$ImageResizeConfigToJson(ImageResizeConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'destination': instance.destination,
      'unit': _$SizeUnitEnumMap[instance.unit]!,
      'height': instance.height,
      'width': instance.width,
      'imageFormat': _$ImageFormatEnumMap[instance.imageFormat]!,
      'filter': _$InterpolationEnumMap[instance.filter]!,
      'jpgQuality': instance.jpgQuality,
      'pngCompression': instance.pngCompression,
      'policy': _$ResizePolicyEnumMap[instance.policy]!,
      'target': _$FileTargetEnumMap[instance.target]!,
      'widthAuto': instance.widthAuto,
      'heightAuto': instance.heightAuto,
      'convertWebpToPng': instance.convertWebpToPng,
    };

const _$SizeUnitEnumMap = {
  SizeUnit.pixel: 'pixel',
  SizeUnit.scale: 'scale',
};

const _$ImageFormatEnumMap = {
  ImageFormat.jpg: 'jpg',
  ImageFormat.png: 'png',
  ImageFormat.bmp: 'bmp',
  ImageFormat.origin: 'origin',
};

const _$InterpolationEnumMap = {
  Interpolation.nearest: 'nearest',
  Interpolation.linear: 'linear',
  Interpolation.cubic: 'cubic',
  Interpolation.area: 'area',
  Interpolation.lanczos4: 'lanczos4',
  Interpolation.linearExact: 'linearExact',
  Interpolation.nearestExact: 'nearestExact',
};

const _$ResizePolicyEnumMap = {
  ResizePolicy.always: 'always',
  ResizePolicy.reduce: 'reduce',
  ResizePolicy.enlarge: 'enlarge',
};

const _$FileTargetEnumMap = {
  FileTarget.origin: 'origin',
  FileTarget.create: 'create',
  FileTarget.move: 'move',
};
