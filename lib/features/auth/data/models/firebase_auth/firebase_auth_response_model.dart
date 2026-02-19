import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/verify_user/verify_user_response_entity.dart';
import '../../models/verify_otp/verify_otp_response_model/delivery_partner.dart';

part 'firebase_auth_response_model.g.dart';

@JsonSerializable()
class FirebaseAuthResponseModel extends VerifyUserResponseEntity {
  @override
  final String? message;
  @override
  @JsonKey(defaultValue: false)
  final bool? isNewUser;
  @override
  final String? token;
  @override
  @JsonKey(name: 'deliveryPartner')
  final DeliveryPartner? deliveryPartner;

  const FirebaseAuthResponseModel({
    this.message,
    this.isNewUser,
    this.token,
    this.deliveryPartner,
  }) : super(
         message: message,
         isNewUser: isNewUser,
         token: token,
         deliveryPartner: deliveryPartner,
       );

  factory FirebaseAuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FirebaseAuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseAuthResponseModelToJson(this);
}
