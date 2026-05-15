import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/get_agent_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.basicInfo,
    this.onEditPhoto,
    this.isUploadingPhoto = false,
    this.pendingPhotoPath,
    this.avgRating,
    this.ratingCount,
    this.isLoadingRating = false,
  });

  final BasicInfoEntity basicInfo;
  final VoidCallback? onEditPhoto;
  final bool isUploadingPhoto;
  final String? pendingPhotoPath;
  final num? avgRating;
  final int? ratingCount;
  final bool isLoadingRating;

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
              _Avatar(
                photo: photo,
                pendingPhotoPath: pendingPhotoPath,
                initials: _initials(basicInfo.fullName),
                isUploading: isUploadingPhoto,
                onEdit: onEditPhoto,
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
                      style: AppTextStyles.mediumTextStyle(
                        context,
                      ).copyWith(color: AppColors.greyTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.start,
            children: [
              _StatusBadge(status: basicInfo.status),
              _ActivePill(isActive: basicInfo.isActive ?? false),
              _RatingPill(
                avgRating: avgRating,
                ratingCount: ratingCount,
                isLoading: isLoadingRating,
              ),
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

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.avgRating,
    required this.ratingCount,
    required this.isLoading,
  });

  final num? avgRating;
  final int? ratingCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xffF59E0B);
    final bg = amber.withValues(alpha: 0.12);

    Widget content;
    if (isLoading && avgRating == null) {
      content = const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 1.6, color: amber),
      );
    } else {
      final avg = (avgRating ?? 0).toDouble();
      final avgText = avg.toStringAsFixed(1);
      final count = ratingCount ?? 0;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: amber),
          const SizedBox(width: 4),
          Text(
            avgText,
            style: AppTextStyles.smallTextStyle(
              context,
            ).copyWith(color: amber, fontWeight: FontWeight.w700),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: AppTextStyles.smallTextStyle(
                context,
              ).copyWith(color: AppColors.greyTextColor),
            ),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: content,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photo,
    required this.pendingPhotoPath,
    required this.initials,
    required this.isUploading,
    required this.onEdit,
  });

  final String? photo;
  final String? pendingPhotoPath;
  final String initials;
  final bool isUploading;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final hasNetwork = photo != null && photo!.isNotEmpty;
    final hasLocalPending =
        pendingPhotoPath != null && pendingPhotoPath!.isNotEmpty;

    DecorationImage? image;
    if (hasLocalPending) {
      image = DecorationImage(
        image: FileImage(File(pendingPhotoPath!)),
        fit: BoxFit.cover,
      );
    } else if (hasNetwork) {
      image = DecorationImage(image: NetworkImage(photo!), fit: BoxFit.cover);
    }

    final hasImage = image != null;

    void handleTap() {
      if (isUploading) return;
      if (hasImage) {
        _showPhotoViewer(
          context,
          networkUrl: hasLocalPending ? null : (hasNetwork ? photo : null),
          localPath: hasLocalPending ? pendingPhotoPath : null,
        );
      } else if (onEdit != null) {
        onEdit!();
      }
    }

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
                image: image,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: handleTap,
                child: Container(
                  alignment: Alignment.center,
                  child: image == null
                      ? Text(
                          initials,
                          style: AppTextStyles.textLargefs20(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          if (isUploading)
            Positioned(
              left: 0,
              top: 0,
              child: IgnorePointer(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (onEdit != null && !isUploading)
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onEdit,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPhotoViewer(
    BuildContext context, {
    String? networkUrl,
    String? localPath,
  }) {
    final ImageProvider provider = localPath != null
        ? FileImage(File(localPath)) as ImageProvider
        : NetworkImage(networkUrl!);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image(image: provider, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        style: AppTextStyles.smallTextStyle(
          context,
        ).copyWith(color: _fg(), fontWeight: FontWeight.w600),
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
            style: AppTextStyles.smallTextStyle(
              context,
            ).copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
