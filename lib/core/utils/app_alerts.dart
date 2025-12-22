import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppAlerts {
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showCustomSnackBar(
      context: context,
      message: message,
      status: 'Success',
      duration: duration,
      backgroundColor: const Color(0xffE6FAF5),
      borderColor: const Color(0xff00CC99),
      icon: Icons.check_rounded,
    );
  }

  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showCustomSnackBar(
      context: context,
      message: message,
      status: 'Error',
      duration: duration,
      backgroundColor: const Color(0xffFFF1F1),
      borderColor: const Color(0xffEE4444),
      icon: Icons.error_outline,
    );
  }

  static Future<bool?> showWarningDialog({
    required BuildContext context,
    String title = 'Warning',
    required String message,
    String confirmText = 'CONFIRM',
    String cancelText = 'CANCEL',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          onConfirm ?? () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showCustomSnackBar({
    required BuildContext context,
    required String message,
    required String status,
    required Duration duration,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
  }) {
    // Start the animation

    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: borderColor, width: 5),
            right: BorderSide(color: borderColor, width: 0.21),
            top: BorderSide(color: borderColor, width: 0.21),
            bottom: BorderSide(color: borderColor, width: 0.21),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: borderColor,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: AppTextStyles.mediumTextStyle(
                      context,
                    ).copyWith(color: borderColor, fontWeight: FontWeight.w500),
                  ),
                  Flexible(
                    child: Text(
                      message,
                      softWrap: true,
                      style: AppTextStyles.smallTextStyle(
                        context,
                      ).copyWith(color: AppColors.greyTextColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).size.height -
            200, // Adjust 100 to position it higher or lower
        right: 20,
        left: 20,
        top: 20, // Add some top margin
      ),
      duration: duration,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
