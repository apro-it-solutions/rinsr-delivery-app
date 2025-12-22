import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/get_orders_entity.dart';

class OrderCancelledView extends StatelessWidget {
  final OrderDetailsEntity order;

  const OrderCancelledView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.redColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.redColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_rounded,
              color: AppColors.redColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Order Cancelled',
            style: AppTextStyles.textMediumfs18(
              context,
            ).copyWith(color: AppColors.redColor),
          ),
          const SizedBox(height: 8),
          Text(
            'This delivery has been cancelled.',
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(color: AppColors.greyText),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            'Reason',
            (order.cancelReason?.isNotEmpty ?? false)
                ? order.cancelReason!
                : 'Others',
          ),
          // We could add Time here if available in entity
          // const SizedBox(height: 12),
          // _buildInfoRow(context, 'Date', DateFormat('MMM dd, hh:mm a').format(DateTime.now())),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.smallTextStyle(
              context,
            ).copyWith(color: AppColors.greyText, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
