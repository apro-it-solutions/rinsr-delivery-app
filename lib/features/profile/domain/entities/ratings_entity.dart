import 'package:equatable/equatable.dart';

class RatingsEntity extends Equatable {
  final String? message;
  final RatingPartnerEntity? deliveryPartner;
  final List<RatingItemEntity> ratings;
  final int? total;
  final int? page;
  final int? totalPages;

  const RatingsEntity({
    this.message,
    this.deliveryPartner,
    this.ratings = const [],
    this.total,
    this.page,
    this.totalPages,
  });

  @override
  List<Object?> get props => [
    message,
    deliveryPartner,
    ratings,
    total,
    page,
    totalPages,
  ];
}

class RatingPartnerEntity extends Equatable {
  final String? id;
  final String? fullName;
  final num? avgRating;
  final int? ratingCount;

  const RatingPartnerEntity({
    this.id,
    this.fullName,
    this.avgRating,
    this.ratingCount,
  });

  @override
  List<Object?> get props => [id, fullName, avgRating, ratingCount];
}

class RatingItemEntity extends Equatable {
  final String? id;
  final RatingUserEntity? user;
  final String? leg;
  final RatingOrderEntity? order;
  final String? comment;
  final num? stars;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RatingItemEntity({
    this.id,
    this.user,
    this.leg,
    this.order,
    this.comment,
    this.stars,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    user,
    leg,
    order,
    comment,
    stars,
    createdAt,
    updatedAt,
  ];
}

class RatingUserEntity extends Equatable {
  final String? id;
  final String? name;

  const RatingUserEntity({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}

class RatingOrderEntity extends Equatable {
  final String? id;
  final int? orderId;

  const RatingOrderEntity({this.id, this.orderId});

  @override
  List<Object?> get props => [id, orderId];
}
