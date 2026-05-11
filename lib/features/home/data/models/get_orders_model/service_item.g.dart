// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceItem _$ServiceItemFromJson(Map<String, dynamic> json) => ServiceItem(
  categoryId: json['category_id'] as String?,
  categoryName: json['category_name'] as String?,
  itemId: json['item_id'] as String?,
  itemName: json['item_name'] as String?,
  pricePerPiece: json['price_per_piece'] as num?,
  pricePerWeight: json['price_per_weight'] as num?,
  avgWeightPerPiece: json['avg_weight_per_piece'] as num?,
  quantity: (json['quantity'] as num?)?.toInt(),
  estimatedWeight: json['estimated_weight'] as num?,
  lineTotal: json['line_total'] as num?,
  id: json['_id'] as String?,
);

Map<String, dynamic> _$ServiceItemToJson(ServiceItem instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'item_id': instance.itemId,
      'item_name': instance.itemName,
      'price_per_piece': instance.pricePerPiece,
      'price_per_weight': instance.pricePerWeight,
      'avg_weight_per_piece': instance.avgWeightPerPiece,
      'quantity': instance.quantity,
      'estimated_weight': instance.estimatedWeight,
      'line_total': instance.lineTotal,
      '_id': instance.id,
    };
