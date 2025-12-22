import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrderInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isHighlight;
  final VoidCallback? onActionTap;

  const OrderInfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.isHighlight = false,
    this.onActionTap,
    this.actionIcon = Icons.map,
  });

  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.green.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? Colors.green : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isHighlight)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlight
                  ? Colors.green.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isHighlight ? Colors.green : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.smallTextStyle(
                    context,
                  ).copyWith(color: AppColors.greyText),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHighlight ? Colors.green : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onActionTap != null)
            IconButton(
              onPressed: onActionTap,
              icon: Icon(actionIcon, color: Colors.blue),
            ),
        ],
      ),
    );
  }
}
