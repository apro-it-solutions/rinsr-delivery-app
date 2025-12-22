import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/continue_button.dart';
import '../../../home/domain/entities/get_orders_entity.dart';

class OrderCompletedView extends StatelessWidget {
  final OrderDetailsEntity order;

  const OrderCompletedView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Order Delivered!',
            style: AppTextStyles.textLargefs20(context).copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.headerTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Great job! You have successfully completed this order.',
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(color: AppColors.greyTextColor, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorderColor),
            ),
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID #',
                  style: AppTextStyles.mediumTextStyle(
                    context,
                  ).copyWith(color: AppColors.greyTextColor),
                ),
                Expanded(
                  child: Text(
                    order.orderId ?? 'N/A',
                    style: AppTextStyles.mediumTextStyle(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.headerTextColor,
                    ),
                    textAlign: TextAlign.start,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ContinueButton(
            text: 'Back to Home',
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
