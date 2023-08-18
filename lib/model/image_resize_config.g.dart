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
      ..height = json['height'] as int
      ..width = json['width'] as int
      ..imageFormat = $enumDecode(_$ImageFormatEnumMap, json['imageFormat'])
      ..filter = $enumDecode(_$InterpolationEnumMap, json['filter'])
      ..jpgQuality = json['jpgQuality'] as int
      ..pngCompression = json['pngCompression'] as int
      ..policy = $enumDecode(_$ResizePolicyEnumMap, json['policy'])
      ..target = $enumDecode(_$FileTargetEnumMap, json['target']);

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
