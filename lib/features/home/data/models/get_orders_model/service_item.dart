import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/get_orders_entity.dart';

part 'service_item.g.dart';

@JsonSerializable()
class ServiceItem extends ServiceItemEntity {
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @override
  @JsonKey(name: 'item_id')
  final String? itemId;
  @override
  @JsonKey(name: 'item_name')
  final String? itemName;
  @override
  @JsonKey(name: 'price_per_piece')
  final num? pricePerPiece;
  @override
  @JsonKey(name: 'price_per_weight')
  final num? pricePerWeight;
  @override
  @JsonKey(name: 'avg_weight_per_piece')
  final num? avgWeightPerPiece;
  @override
  final int? quantity;
  @override
  @JsonKey(name: 'estimated_weight')
  final num? estimatedWeight;
  @override
  @JsonKey(name: 'line_total')
  final num? lineTotal;
  @override
  @JsonKey(name: '_id')
  final String? id;

  const ServiceItem({
    this.categoryId,
    this.categoryName,
    this.itemId,
    this.itemName,
    this.pricePerPiece,
    this.pricePerWeight,
    this.avgWeightPerPiece,
    this.quantity,
    this.estimatedWeight,
    this.lineTotal,
    this.id,
  }) : super(
         categoryId: categoryId,
         categoryName: categoryName,
         itemId: itemId,
         itemName: itemName,
         pricePerPiece: pricePerPiece,
         pricePerWeight: pricePerWeight,
         avgWeightPerPiece: avgWeightPerPiece,
         quantity: quantity,
         estimatedWeight: estimatedWeight,
         lineTotal: lineTotal,
         id: id,
       );

  factory ServiceItem.fromJson(Map<String, dynamic> json) =>
      _$ServiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceItemToJson(this);
}
