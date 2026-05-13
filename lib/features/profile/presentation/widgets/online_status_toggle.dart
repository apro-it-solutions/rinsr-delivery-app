import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/profile_bloc.dart';

class OnlineStatusToggle extends StatelessWidget {
  const OnlineStatusToggle({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          current is ToggleActiveLoadingState ||
          current is ProfileDetailsLoadedState,
      builder: (context, state) {
        final loading = state is ToggleActiveLoadingState;
        final pendingValue = loading ? state.isActive : isActive;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorderColor),
            boxShadow: [AppDecoration.commonShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: pendingValue
                      ? const Color(0xffE8F8EF)
                      : const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  pendingValue ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  size: 18,
                  color: pendingValue
                      ? const Color(0xff138A4F)
                      : AppColors.greyTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pendingValue ? 'You\'re Online' : 'You\'re Offline',
                      style: AppTextStyles.textMediumfs16(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.headerTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pendingValue
                          ? 'You will receive new order requests'
                          : 'You won\'t receive new orders',
                      style: AppTextStyles.smallTextStyle(
                        context,
                      ).copyWith(color: AppColors.greyTextColor),
                    ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                Switch.adaptive(
                  value: pendingValue,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: AppColors.dividerColor,
                  inactiveTrackColor: AppColors.lightBorderColor,
                  onChanged: (value) {
                    context.read<ProfileBloc>().add(
                      ToggleActiveEvent(isActive: value),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
