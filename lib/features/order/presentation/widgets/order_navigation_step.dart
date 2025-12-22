import 'package:flutter/material.dart';
import '../../../../core/widgets/slide_action_button.dart';
import 'order_info_card.dart';

class OrderNavigationStep extends StatelessWidget {
  final String title;
  final String address;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final VoidCallback onActionTap;

  const OrderNavigationStep({
    super.key,
    required this.title,
    required this.address,
    required this.buttonText,
    required this.onButtonPressed,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderInfoCard(
          title: title,
          content: address,
          icon: Icons.location_on,
          onActionTap: onActionTap,
        ),
        const SizedBox(height: 32),
        SlideActionButton(
          text: buttonText,
          onSlideCompleted: onButtonPressed,
          icon: Icons.double_arrow_rounded,
        ),
      ],
    );
  }
}
