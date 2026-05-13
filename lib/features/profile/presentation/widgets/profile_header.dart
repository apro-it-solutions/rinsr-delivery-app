import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/get_agent_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.basicInfo});

  final BasicInfoEntity basicInfo;

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final photo = basicInfo.photo;
    final memberSince = basicInfo.memberSince != null
        ? formatDateMMMDDYYYY(basicInfo.memberSince!)
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [AppDecoration.commonShadow],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  image: photo != null && photo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photo),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: photo == null || photo.isEmpty
                    ? Text(
                        _initials(basicInfo.fullName),
                        style: AppTextStyles.textLargefs20(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      basicInfo.fullName ?? '—',
                      style: AppTextStyles.textMediumfs18(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.headerTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      basicInfo.phoneNumber ?? '—',
                      style: AppTextStyles.mediumTextStyle(context).copyWith(
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusBadge(status: basicInfo.status),
              const SizedBox(width: 8),
              _ActivePill(isActive: basicInfo.isActive ?? false),
              const Spacer(),
              if (memberSince != null)
                Text(
                  'Since $memberSince',
                  style: AppTextStyles.smallTextStyle(context),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({this.status});
  final String? status;

  Color _bg() {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'active':
        return const Color(0xffE8F8EF);
      case 'documents pending':
      case 'pending':
        return const Color(0xffFFF4E0);
      case 'rejected':
      case 'suspended':
        return const Color(0xffFFE5E5);
      default:
        return AppColors.lightSurface;
    }
  }

  Color _fg() {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'verified':
      case 'active':
        return const Color(0xff138A4F);
      case 'documents pending':
      case 'pending':
        return const Color(0xffB45309);
      case 'rejected':
      case 'suspended':
        return AppColors.redColor;
      default:
        return AppColors.greyTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = status == null || status!.isEmpty ? 'Unknown' : status!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: AppTextStyles.smallTextStyle(context).copyWith(
          color: _fg(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xff138A4F) : AppColors.greyTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: AppTextStyles.smallTextStyle(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
