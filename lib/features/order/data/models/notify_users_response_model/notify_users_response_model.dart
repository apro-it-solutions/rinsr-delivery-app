import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/notify_user_response_entity.dart';

part 'notify_users_response_model.g.dart';

@JsonSerializable()
class NotifyUsersResponseModel extends NotifyUserResponseEntity {
  const NotifyUsersResponseModel({super.success, super.message});

  factory NotifyUsersResponseModel.fromJson(Map<String, dynamic> json) {
    return _$NotifyUsersResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotifyUsersResponseModelToJson(this);

  NotifyUsersResponseModel copyWith({bool? success, String? message}) {
    return NotifyUsersResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }
}
