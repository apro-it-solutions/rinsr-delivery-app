import '../../domain/entities/ratings_entity.dart';

class RatingsModel extends RatingsEntity {
  const RatingsModel({
    super.message,
    super.deliveryPartner,
    super.ratings,
    super.total,
    super.page,
    super.totalPages,
  });

  factory RatingsModel.fromJson(Map<String, dynamic> json) {
    final partner = json['delivery_partner'];
    final list = json['ratings'];
    return RatingsModel(
      message: json['message'] as String?,
      deliveryPartner: partner is Map<String, dynamic>
          ? RatingPartnerModel.fromJson(partner)
          : null,
      ratings: list is List
          ? list
                .whereType<Map<String, dynamic>>()
                .map(RatingItemModel.fromJson)
                .toList()
          : const [],
      total: (json['total'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );
  }
}

class RatingPartnerModel extends RatingPartnerEntity {
  const RatingPartnerModel({
    super.id,
    super.fullName,
    super.avgRating,
    super.ratingCount,
  });

  factory RatingPartnerModel.fromJson(Map<String, dynamic> json) {
    return RatingPartnerModel(
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      avgRating: json['avg_rating'] as num?,
      ratingCount: (json['rating_count'] as num?)?.toInt(),
    );
  }
}

class RatingItemModel extends RatingItemEntity {
  const RatingItemModel({
    super.id,
    super.user,
    super.leg,
    super.order,
    super.comment,
    super.stars,
    super.createdAt,
    super.updatedAt,
  });

  factory RatingItemModel.fromJson(Map<String, dynamic> json) {
    final user = json['user_id'];
    final order = json['order_id'];
    final createdRaw = json['createdAt'];
    final updatedRaw = json['updatedAt'];
    return RatingItemModel(
      id: json['_id'] as String?,
      user: user is Map<String, dynamic>
          ? RatingUserModel.fromJson(user)
          : null,
      leg: json['leg'] as String?,
      order: order is Map<String, dynamic>
          ? RatingOrderModel.fromJson(order)
          : null,
      comment: json['comment'] as String?,
      stars: json['stars'] as num?,
      createdAt: createdRaw is String ? DateTime.tryParse(createdRaw) : null,
      updatedAt: updatedRaw is String ? DateTime.tryParse(updatedRaw) : null,
    );
  }
}

class RatingUserModel extends RatingUserEntity {
  const RatingUserModel({super.id, super.name});

  factory RatingUserModel.fromJson(Map<String, dynamic> json) {
    return RatingUserModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
    );
  }
}

class RatingOrderModel extends RatingOrderEntity {
  const RatingOrderModel({super.id, super.orderId});

  factory RatingOrderModel.fromJson(Map<String, dynamic> json) {
    return RatingOrderModel(
      id: json['_id'] as String?,
      orderId: (json['order_id'] as num?)?.toInt(),
    );
  }
}
