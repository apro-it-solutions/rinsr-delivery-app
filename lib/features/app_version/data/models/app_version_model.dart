import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_version_entity.dart';

part 'app_version_model.g.dart';

@JsonSerializable()
class AppVersionModel extends AppVersionEntity {
  @JsonKey(name: 'min_supported_version')
  final String? minSupportedVersionField;

  @JsonKey(name: 'ios_store_url')
  final String? iosStoreUrlField;

  @JsonKey(name: 'android_store_url')
  final String? androidStoreUrlField;

  const AppVersionModel({
    this.minSupportedVersionField,
    this.iosStoreUrlField,
    this.androidStoreUrlField,
  }) : super(
         minSupportedVersion: minSupportedVersionField,
         iosStoreUrl: iosStoreUrlField,
         androidStoreUrl: androidStoreUrlField,
       );

  factory AppVersionModel.fromJson(Map<String, dynamic> json) =>
      _$AppVersionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionModelToJson(this);
}
