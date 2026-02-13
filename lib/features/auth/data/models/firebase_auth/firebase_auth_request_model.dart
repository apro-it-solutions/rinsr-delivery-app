import 'package:json_annotation/json_annotation.dart';

part 'firebase_auth_request_model.g.dart';

@JsonSerializable()
class FirebaseAuthRequestModel {
  final String idToken;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  FirebaseAuthRequestModel({required this.idToken, this.fcmToken});

  factory FirebaseAuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseAuthRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseAuthRequestModelToJson(this);
}
