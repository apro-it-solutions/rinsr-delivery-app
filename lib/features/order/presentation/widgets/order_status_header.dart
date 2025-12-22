import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/constants/status_extensions.dart';

class OrderStatusHeader extends StatelessWidget {
  final OrderStatus status;
  final TaskType type;

  const OrderStatusHeader({
    super.key,
    required this.status,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // simplified status logic from extension
    final agentStatus = status.agentStatus;

    if (agentStatus == DeliveryAgentStatus.cancelled) {
      return _buildCancelledHeader(context);
    }

    final currentStep = agentStatus.index;
    // Enum order: pickup(0), transit(1), delivered(2).
    // This matches our previous logic. Warning: verify enum order!
    // DeliveryAgentStatus: pickup, transit, delivered, cancelled, unknown.
    // pickup=0, transit=1, delivered=2. This works.

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Layer 1: Connectors (Lines)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              children: [
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 2,
                    color: currentStep > 0
                        ? AppColors.primary
                        : Colors.grey.shade200,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 2,
                    color: currentStep > 1
                        ? AppColors.primary
                        : Colors.grey.shade200,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
          // Layer 2: Steps (Circles + Text)
          Row(
            children: [
              _buildStepItem(
                context,
                0,
                DeliveryAgentStatus.pickup.label,
                currentStep,
              ),
              _buildStepItem(
                context,
                1,
                DeliveryAgentStatus.transit.label,
                currentStep,
              ),
              _buildStepItem(
                context,
                2,
                DeliveryAgentStatus.delivered.label,
                currentStep,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    int stepIndex,
    String label,
    int currentStep,
  ) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;

    Color circleColor;
    Color iconColor;
    if (isCompleted || isActive) {
      circleColor = AppColors.primary;
      iconColor = Colors.white;
    } else {
      circleColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade400;
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : isActive
                  ? const Icon(Icons.circle, size: 12, color: Colors.white)
                  : Text(
                      (stepIndex + 1).toString(),
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.smallTextStyle(context).copyWith(
              color: isActive || isCompleted
                  ? AppColors.primary
                  : AppColors.greyText,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redColor.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          'CANCELLED',
          style: AppTextStyles.mediumTextStyle(context).copyWith(
            color: AppColors.redColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
