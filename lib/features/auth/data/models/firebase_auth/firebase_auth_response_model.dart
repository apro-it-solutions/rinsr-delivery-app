import 'package:json_annotation/json_annotation.dart';
import '../../models/verify_otp/verify_otp_response_model/delivery_partner.dart';

part 'firebase_auth_response_model.g.dart';

@JsonSerializable()
class FirebaseAuthResponseModel {
  final String message;
  final bool isNewUser;
  final String token;
  @JsonKey(name: 'user')
  final DeliveryPartner user;

  FirebaseAuthResponseModel({
    required this.message,
    required this.isNewUser,
    required this.token,
    required this.user,
  });

  factory FirebaseAuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseAuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseAuthResponseModelToJson(this);
}
