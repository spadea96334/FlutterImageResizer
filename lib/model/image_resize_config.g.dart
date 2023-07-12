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
      ..height = json['height'] as int
      ..width = json['width'] as int
      ..imageFormat = $enumDecode(_$ImageFormatEnumMap, json['imageFormat'])
      ..filter = $enumDecode(_$InterpolationEnumMap, json['filter'])
      ..jpgQuality = json['jpgQuality'] as int
      ..pngCompression = json['pngCompression'] as int
      ..scaleX = json['scaleX'] as int
      ..scaleY = json['scaleY'] as int;

Map<String, dynamic> _$ImageResizeConfigToJson(ImageResizeConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'destination': instance.destination,
      'height': instance.height,
      'width': instance.width,
      'imageFormat': _$ImageFormatEnumMap[instance.imageFormat]!,
      'filter': _$InterpolationEnumMap[instance.filter]!,
      'jpgQuality': instance.jpgQuality,
      'pngCompression': instance.pngCompression,
      'scaleX': instance.scaleX,
      'scaleY': instance.scaleY,
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
