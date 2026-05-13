import '../../domain/entities/toggle_active_entity.dart';

class ToggleActiveModel extends ToggleActiveEntity {
  const ToggleActiveModel({
    super.success,
    super.message,
    super.deliveryPartner,
  });

  factory ToggleActiveModel.fromJson(Map<String, dynamic> json) {
    final partner = json['delivery_partner'];
    return ToggleActiveModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      deliveryPartner: partner is Map<String, dynamic>
          ? ToggleActiveDataModel.fromJson(partner)
          : null,
    );
  }
}

class ToggleActiveDataModel extends ToggleActiveData {
  const ToggleActiveDataModel({super.id, super.fullName, super.isActive});

  factory ToggleActiveDataModel.fromJson(Map<String, dynamic> json) {
    return ToggleActiveDataModel(
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }
}
