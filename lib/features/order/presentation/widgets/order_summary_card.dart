import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/get_orders_entity.dart';
import 'order_itemized_list.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderDetailsEntity order;

  const OrderSummaryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Determine payment status color and text
    final isPaid = order.paymentStatus?.toLowerCase() == 'paid';
    final paymentStatusColor = isPaid ? Colors.green : Colors.orange;
    final paymentStatusText = order.paymentStatus?.toUpperCase() ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.greyText.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 16,
                color: AppColors.greyText,
              ),
              const SizedBox(width: 6),
              Text(
                order.displayOrderID != null
                    ? 'ORDER #RIN-${order.displayOrderID}'
                    : 'ORDER ID UNAVAILABLE',
                style: AppTextStyles.smallTextStyle(context).copyWith(
                  color: AppColors.greyText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.isPerPiece ? 'TOTAL VALUE' : 'ESTIMATED VALUE',
                    style: AppTextStyles.smallTextStyle(context).copyWith(
                      color: AppColors.greyText,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${order.estimateTotalPrice ?? 0}',
                    style: AppTextStyles.largeTextStyle(context).copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: paymentStatusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: paymentStatusColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  paymentStatusText,
                  style: AppTextStyles.smallTextStyle(context).copyWith(
                    color: paymentStatusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                context,
                icon: Icons.local_laundry_service_outlined,
                label: 'Service',
                value: order.serviceId?.name ?? 'Standard',
              ),
              if (order.isPerPiece) ...[
                _buildVerticalDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.checkroom_outlined,
                  label: 'Quantity',
                  value: _quantityValue(order),
                ),
              ] else if (_weightValue(order) != null) ...[
                _buildVerticalDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.scale_outlined,
                  label: 'Weight',
                  value: _weightValue(order)!,
                ),
              ],
            ],
          ),
          if (order.isPerPiece) ...[
            const SizedBox(height: 16),
            OrderItemizedList(
              services: order.services,
              fallbackItems: order.selectedClothingItems,
              collapsible: true,
            ),
          ],
        ],
      ),
    );
  }

  String _quantityValue(OrderDetailsEntity order) {
    if (order.isPerPiece) {
      final pieces = order.aggregatePieceCount;
      if (pieces > 0) return '$pieces pcs';
    }
    final raw = order.totalNoOfClothes;
    if (raw != null && raw.isNotEmpty) return '$raw pcs';
    return '--';
  }

  String? _weightValue(OrderDetailsEntity order) {
    final raw = order.totalWeightKg;
    if (raw == null || raw.isEmpty) return null;
    return '$raw kg';
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.greyText.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.greyText),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.smallTextStyle(
                  context,
                ).copyWith(color: AppColors.greyText, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
