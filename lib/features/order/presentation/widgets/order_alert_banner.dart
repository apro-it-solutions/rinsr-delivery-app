import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrderAlertBanner extends StatelessWidget {
  final String title;
  final String? message;
  final Color color;
  final IconData icon;

  const OrderAlertBanner({
    super.key,
    required this.title,
    this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textMediumfs16(
                    context,
                  ).copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: AppTextStyles.smallTextStyle(
                      context,
                    ).copyWith(color: color.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
