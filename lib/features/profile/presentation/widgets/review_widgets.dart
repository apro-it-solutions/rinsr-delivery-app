import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/ratings_entity.dart';

class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({
    super.key,
    required this.avgRating,
    required this.total,
  });

  final num? avgRating;
  final int total;

  @override
  Widget build(BuildContext context) {
    final avg = (avgRating ?? 0).toDouble();
    final avgText = avg.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [AppDecoration.commonShadow],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    avgText,
                    style: AppTextStyles.largeTextStyle(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.headerTextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/5',
                      style: AppTextStyles.smallTextStyle(context).copyWith(
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              StarsRow(value: avg, size: 16),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total',
                style: AppTextStyles.textMediumfs18(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headerTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                total == 1 ? 'review' : 'reviews',
                style: AppTextStyles.smallTextStyle(context).copyWith(
                  color: AppColors.greyTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.item});

  final RatingItemEntity item;

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  String _humanize(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final stars = (item.stars ?? 0).toDouble();
    final name = item.user?.name ?? 'Anonymous';
    final orderId = item.order?.orderId;
    final leg = _humanize(item.leg);
    final created = item.createdAt;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [AppDecoration.commonShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.mediumTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.headerTextColor,
                      ),
                    ),
                    if (created != null)
                      Text(
                        formatDateMMMDDYYYY(created),
                        style: AppTextStyles.smallTextStyle(context).copyWith(
                          color: AppColors.greyTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              StarsRow(value: stars, size: 14),
            ],
          ),
          const SizedBox(height: 10),
          if (item.comment != null && item.comment!.isNotEmpty)
            Text(
              item.comment!,
              style: AppTextStyles.mediumTextStyle(context).copyWith(
                color: AppColors.textColor,
              ),
            ),
          if (orderId != null || leg.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (orderId != null)
                  _MetaChip(
                    icon: Icons.receipt_long_outlined,
                    label: 'Order #$orderId',
                  ),
                if (leg.isNotEmpty)
                  _MetaChip(
                    icon: leg.toLowerCase() == 'return'
                        ? Icons.assignment_return_outlined
                        : Icons.local_shipping_outlined,
                    label: leg,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.greyTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.smallTextStyle(context).copyWith(
              color: AppColors.greyTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class StarsRow extends StatelessWidget {
  const StarsRow({super.key, required this.value, this.size = 16});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value.round();
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? const Color(0xffF59E0B) : AppColors.inactiveGreyColor,
        );
      }),
    );
  }
}

class EmptyReviews extends StatelessWidget {
  const EmptyReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorderColor),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.reviews_outlined,
              size: 32,
              color: AppColors.inactiveGreyColor,
            ),
            const SizedBox(height: 8),
            Text(
              'No reviews yet',
              style: AppTextStyles.smallTextStyle(context).copyWith(
                color: AppColors.greyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
