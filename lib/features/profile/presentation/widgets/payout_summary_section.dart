import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/get_agent_entity.dart';

class PayoutSummarySection extends StatelessWidget {
  const PayoutSummarySection({super.key, required this.payout});

  final PayoutDetailsEntity payout;

  String _money(num? v) {
    final value = (v ?? 0).toDouble();
    return '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String _km(num? v) {
    final value = (v ?? 0).toDouble();
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} km';
  }

  @override
  Widget build(BuildContext context) {
    final today = payout.today;
    final summary = payout.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xff1AAB9B)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppDecoration.commonShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Earnings",
                    style: AppTextStyles.mediumTextStyle(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _PaymentChip(status: today?.paymentStatus),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _money(today?.amount),
                style: AppTextStyles.largeTextStyle(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_km(today?.distanceKm)} delivered today',
                style: AppTextStyles.smallTextStyle(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              if (payout.pricePerKilometre != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_money(payout.pricePerKilometre)}/km',
                    style: AppTextStyles.smallTextStyle(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total earned',
                value: _money(summary?.totalEarned),
                accent: const Color(0xff138A4F),
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Total paid',
                value: _money(summary?.totalPaid),
                accent: AppColors.primary,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Pending',
                value: _money(summary?.totalPending),
                accent: const Color(0xffB45309),
                icon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Distance',
                value: _km(summary?.totalDistanceKm),
                accent: const Color(0xff2563EB),
                icon: Icons.route_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Days worked',
                value: '${summary?.daysWorked ?? 0}',
                accent: const Color(0xff7C3AED),
                icon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Completed orders',
                value: '${payout.totalCompletedOrders ?? 0}',
                accent: const Color(0xff0EA5E9),
                icon: Icons.local_shipping_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorderColor),
        boxShadow: [AppDecoration.commonShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.smallTextStyle(context).copyWith(
              color: AppColors.greyTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.textMediumfs16(context).copyWith(
              color: AppColors.headerTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({this.status});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final value = (status ?? 'pending').toLowerCase();
    final isPaid = value == 'paid';
    final color = isPaid ? const Color(0xff138A4F) : const Color(0xffB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Pending',
        style: AppTextStyles.smallTextStyle(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
