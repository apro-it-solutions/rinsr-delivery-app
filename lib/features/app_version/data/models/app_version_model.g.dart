// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionModel _$AppVersionModelFromJson(Map<String, dynamic> json) =>
    AppVersionModel(
      minSupportedVersionField: json['min_supported_version'] as String?,
      iosStoreUrlField: json['ios_store_url'] as String?,
      androidStoreUrlField: json['android_store_url'] as String?,
    );

Map<String, dynamic> _$AppVersionModelToJson(AppVersionModel instance) =>
    <String, dynamic>{
      'min_supported_version': instance.minSupportedVersionField,
      'ios_store_url': instance.iosStoreUrlField,
      'android_store_url': instance.androidStoreUrlField,
    };
