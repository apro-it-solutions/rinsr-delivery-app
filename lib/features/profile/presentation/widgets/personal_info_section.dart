import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'build_textfield.dart';

class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({
    super.key,
    required this.companyNameController,
    required this.serviceController,
    required this.addressController,
    required this.phoneNumberController,
  });
  final TextEditingController companyNameController;
  final TextEditingController serviceController;
  final TextEditingController addressController;
  final TextEditingController phoneNumberController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [AppDecoration.commonShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16,
              top: 16,
              bottom: 5,
            ),
            child: Text(
              'Agent Information',
              style: AppTextStyles.textMediumfs16(context).copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.headerTextColor,
              ),
            ),
          ),
          const Divider(color: AppColors.lightBorderColor),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Name',
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    color: const Color(0xff374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                BuildTextfield(
                  hintText: 'Enter your name',
                  controller: companyNameController,
                ),
                const SizedBox(height: 14),
                Text(
                  'Services',
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    color: const Color(0xff374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                BuildTextfield(
                  hintText: 'Enter your email address',
                  controller: serviceController,
                ),
                const SizedBox(height: 14),
                Text(
                  'Location',
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    color: const Color(0xff374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                BuildTextfield(
                  hintText: 'Enter your phone number',
                  controller: addressController,
                ),
                const SizedBox(height: 14),
                Text(
                  'Phone Number',
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    color: const Color(0xff374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                BuildTextfield(
                  hintText: 'Enter your phone number',
                  controller: phoneNumberController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
