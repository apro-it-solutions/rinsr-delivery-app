import 'package:flutter/material.dart';

import '../utils/responsive_utils.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle smallTextStyle(BuildContext context) => TextStyle(
    fontSize: 12.w(context),
    fontWeight: FontWeight.w400,
    color: AppColors.greyText,
  );

  static TextStyle hintTextStyle(BuildContext context) => TextStyle(
    fontSize: 16.w(context),
    fontWeight: FontWeight.w400,
    color: AppColors.hintTextColor,
  );
  static TextStyle textMediumfs16(BuildContext context) => TextStyle(
    fontSize: 16.w(context),
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static TextStyle mediumTextStyle(BuildContext context) => TextStyle(
    fontSize: 14.w(context),
    fontWeight: FontWeight.w400,
    color: AppColors.textColor,
  );

  static TextStyle textMediumfs18(BuildContext context) => TextStyle(
    fontSize: 18.w(context),
    fontWeight: FontWeight.w500,
    color: AppColors.textColor,
  );

  static TextStyle textLargefs20(BuildContext context) => TextStyle(
    fontSize: 20.w(context),
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );
  static TextStyle largeTextStyle(BuildContext context) => TextStyle(
    fontSize: 24.w(context),
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );
}
