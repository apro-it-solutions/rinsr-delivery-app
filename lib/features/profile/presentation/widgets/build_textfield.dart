import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BuildTextfield extends StatelessWidget {
  const BuildTextfield({
    super.key,
    required this.hintText,
    required this.controller,
    this.isSuffixIcon = false,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController controller;
  final bool isSuffixIcon;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: null,
      minLines: 1,
      enabled: false,
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.mediumTextStyle(
        context,
      ).copyWith(color: AppColors.headerTextColor),
      decoration: InputDecoration(
        suffixIconConstraints: const BoxConstraints(
          minHeight: 10,
          minWidth: 10,
        ),
        suffixIcon: isSuffixIcon
            ? Padding(
                padding: const EdgeInsets.only(right: 17.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              )
            : null,
        filled: true,
        hintText: hintText,
        hintStyle: AppTextStyles.hintTextStyle(context),
        fillColor: const Color(0xffF9FAFB),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
