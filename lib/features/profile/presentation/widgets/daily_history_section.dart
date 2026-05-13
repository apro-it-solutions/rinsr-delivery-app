import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/get_agent_entity.dart';

class DailyHistorySection extends StatelessWidget {
  const DailyHistorySection({super.key, required this.history});

  final List<DailyHistoryEntity> history;

  String _money(num? v) {
    final value = (v ?? 0).toDouble();
    return '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String _km(num? v) {
    final value = (v ?? 0).toDouble();
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} km';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return formatDateMMMDDYYYY(parsed);
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.history_toggle_off,
                color: AppColors.inactiveGreyColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                'No history yet',
                style: AppTextStyles.smallTextStyle(
                  context,
                ).copyWith(color: AppColors.greyTextColor),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < history.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(history[i].date),
                        style: AppTextStyles.mediumTextStyle(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.headerTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _km(history[i].distanceKm),
                        style: AppTextStyles.smallTextStyle(context),
                      ),
                    ],
                  ),
                ),
                Text(
                  _money(history[i].amount),
                  style: AppTextStyles.mediumTextStyle(context).copyWith(
                    color: AppColors.headerTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (i != history.length - 1)
            const Divider(height: 1, color: AppColors.lightBorderColor),
        ],
      ],
    );
  }
}
