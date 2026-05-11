import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/get_orders_entity.dart';

/// Renders a per_piece order's items grouped by service. Used in the pickup
/// checklist (showPrices false) and on the drop-off leg / order summary
/// (showPrices true).
class OrderItemizedList extends StatelessWidget {
  final List<ServiceLineEntity>? services;
  final List<ServiceItemEntity>? fallbackItems;
  final bool showPrices;
  final String emptyMessage;

  const OrderItemizedList({
    super.key,
    required this.services,
    this.fallbackItems,
    this.showPrices = false,
    this.emptyMessage = 'No items in this order.',
  });

  List<_GroupedServiceLine> _resolveGroups() {
    if (services != null && services!.isNotEmpty) {
      return services!
          .map(
            (s) => _GroupedServiceLine(
              serviceName: s.serviceName ?? 'Service',
              items: s.items ?? const [],
              subtotal: s.subtotal,
            ),
          )
          .toList();
    }
    if (fallbackItems != null && fallbackItems!.isNotEmpty) {
      return [
        _GroupedServiceLine(
          serviceName: 'Items',
          items: fallbackItems!,
          subtotal: null,
        ),
      ];
    }
    return const [];
  }

  num _aggregateTotal(List<_GroupedServiceLine> groups) {
    return groups.fold<num>(
      0,
      (sum, g) =>
          sum +
          (g.subtotal ??
              g.items.fold<num>(0, (s, i) => s + i.computedLineTotal)),
    );
  }

  int _aggregatePieces(List<_GroupedServiceLine> groups) {
    return groups.fold<int>(
      0,
      (sum, g) =>
          sum + g.items.fold<int>(0, (s, i) => s + (i.quantity ?? 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _resolveGroups();
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          emptyMessage,
          style: AppTextStyles.smallTextStyle(
            context,
          ).copyWith(color: AppColors.greyText),
        ),
      );
    }

    final pieces = _aggregatePieces(groups);
    final total = _aggregateTotal(groups);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.checklist_rtl,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order items',
                  style: AppTextStyles.mediumTextStyle(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '$pieces ${pieces == 1 ? 'piece' : 'pieces'}',
                  style: AppTextStyles.smallTextStyle(
                    context,
                  ).copyWith(color: AppColors.greyText),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final group in groups) ...[
            _ServiceHeader(name: group.serviceName),
            for (final item in group.items)
              _ItemRow(item: item, showPrices: showPrices),
            if (showPrices && group.subtotal != null) ...[
              _SubtotalRow(label: 'Subtotal', amount: group.subtotal!),
              const Divider(height: 1),
            ] else
              const Divider(height: 1),
          ],
          if (showPrices)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.mediumTextStyle(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '₹${_formatNum(total)}',
                    style: AppTextStyles.mediumTextStyle(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupedServiceLine {
  final String serviceName;
  final List<ServiceItemEntity> items;
  final num? subtotal;
  const _GroupedServiceLine({
    required this.serviceName,
    required this.items,
    required this.subtotal,
  });
}

class _ServiceHeader extends StatelessWidget {
  final String name;
  const _ServiceHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        name,
        style: AppTextStyles.smallTextStyle(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ServiceItemEntity item;
  final bool showPrices;
  const _ItemRow({required this.item, required this.showPrices});

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity ?? 0;
    final ppp = item.pricePerPiece;
    final lineTotal = item.computedLineTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.dry_cleaning_outlined,
            size: 20,
            color: AppColors.greyText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? 'Item',
                  style: AppTextStyles.mediumTextStyle(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                if (showPrices && ppp != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '₹${_formatNum(ppp)}/pc',
                    style: AppTextStyles.smallTextStyle(
                      context,
                    ).copyWith(color: AppColors.greyText),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'x$qty',
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          if (showPrices) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(
                '₹${_formatNum(lineTotal)}',
                textAlign: TextAlign.right,
                style: AppTextStyles.mediumTextStyle(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubtotalRow extends StatelessWidget {
  final String label;
  final num amount;
  const _SubtotalRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.smallTextStyle(
              context,
            ).copyWith(color: AppColors.greyText),
          ),
          const Spacer(),
          Text(
            '₹${_formatNum(amount)}',
            style: AppTextStyles.smallTextStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _formatNum(num n) {
  if (n == n.truncateToDouble()) return n.toInt().toString();
  return n.toStringAsFixed(2);
}
