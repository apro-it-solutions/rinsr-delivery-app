import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'user_id.g.dart';

@JsonSerializable()
class UserId extends UserIdEntity {
  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey(name: 'login_method')
  final String? loginMethod;
  @override
  @JsonKey(name: 'is_verified')
  final bool? isVerified;
  @override
  @JsonKey(name: 'phone_verified')
  final bool? phoneVerified;
  @override
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @override
  @JsonKey(name: 'token_version')
  final int? tokenVersion;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  final dynamic profileImage;
  @override
  @JsonKey(name: 'device_tokens')
  final List<String>? deviceTokens;

  const UserId({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.loginMethod,
    this.isVerified,
    this.phoneVerified,
    this.emailVerified,
    this.tokenVersion,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.profileImage,
    this.deviceTokens,
  }) : super(
         id: id,
         name: name,
         phone: phone,
         email: email,
         loginMethod: loginMethod,
         isVerified: isVerified,
         phoneVerified: phoneVerified,
         emailVerified: emailVerified,
         tokenVersion: tokenVersion,
         createdAt: createdAt,
         updatedAt: updatedAt,
         v: v,
         profileImage: profileImage,
         deviceTokens: deviceTokens,
       );

  factory UserId.fromJson(Map<String, dynamic> json) {
    return _$UserIdFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserIdToJson(this);

  UserId copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? loginMethod,
    bool? isVerified,
    bool? phoneVerified,
    bool? emailVerified,
    int? tokenVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    dynamic profileImage,
    List<String>? deviceTokens,
  }) {
    return UserId(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      loginMethod: loginMethod ?? this.loginMethod,
      isVerified: isVerified ?? this.isVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      tokenVersion: tokenVersion ?? this.tokenVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      profileImage: profileImage ?? this.profileImage,
      deviceTokens: deviceTokens ?? this.deviceTokens,
    );
  }
}
