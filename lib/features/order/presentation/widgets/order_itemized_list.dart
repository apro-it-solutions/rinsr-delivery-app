import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/get_orders_entity.dart';

/// Renders a per_piece order's items grouped by service, showing item names
/// and quantities only. Pricing is intentionally not displayed to the
/// delivery agent.
class OrderItemizedList extends StatefulWidget {
  final List<ServiceLineEntity>? services;
  final List<ServiceItemEntity>? fallbackItems;
  final String emptyMessage;
  final bool collapsible;
  final int collapsedItemLimit;

  const OrderItemizedList({
    super.key,
    required this.services,
    this.fallbackItems,
    this.emptyMessage = 'No items in this order.',
    this.collapsible = false,
    this.collapsedItemLimit = 3,
  });

  @override
  State<OrderItemizedList> createState() => _OrderItemizedListState();
}

class _OrderItemizedListState extends State<OrderItemizedList> {
  bool _expanded = false;

  List<_GroupedServiceLine> _resolveGroups() {
    final services = widget.services;
    final fallback = widget.fallbackItems;
    if (services != null && services.isNotEmpty) {
      return services
          .map(
            (s) => _GroupedServiceLine(
              serviceName: s.serviceName ?? 'Service',
              items: s.items ?? const [],
            ),
          )
          .toList();
    }
    if (fallback != null && fallback.isNotEmpty) {
      return [
        _GroupedServiceLine(
          serviceName: 'Items',
          items: fallback,
        ),
      ];
    }
    return const [];
  }

  /// Cap each group's items by the remaining quota. Groups whose quota
  /// reaches 0 mid-way still render their header so the user can see what
  /// is hidden, but their items are truncated.
  List<_GroupedServiceLine> _applyCap(
    List<_GroupedServiceLine> groups,
    int limit,
  ) {
    int remaining = limit;
    final capped = <_GroupedServiceLine>[];
    for (final g in groups) {
      if (remaining <= 0) {
        capped.add(
          _GroupedServiceLine(serviceName: g.serviceName, items: const []),
        );
        continue;
      }
      final take = g.items.length <= remaining ? g.items.length : remaining;
      remaining -= take;
      capped.add(
        _GroupedServiceLine(
          serviceName: g.serviceName,
          items: g.items.sublist(0, take),
        ),
      );
    }
    return capped;
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
          widget.emptyMessage,
          style: AppTextStyles.smallTextStyle(
            context,
          ).copyWith(color: AppColors.greyText),
        ),
      );
    }

    final pieces = _aggregatePieces(groups);
    final totalItems = groups.fold<int>(0, (sum, g) => sum + g.items.length);
    final shouldCollapse =
        widget.collapsible &&
        !_expanded &&
        totalItems > widget.collapsedItemLimit;
    final visibleGroups = shouldCollapse
        ? _applyCap(groups, widget.collapsedItemLimit)
        : groups;
    final hiddenCount = shouldCollapse
        ? totalItems - widget.collapsedItemLimit
        : 0;
    final showToggle =
        widget.collapsible && totalItems > widget.collapsedItemLimit;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: showToggle
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Padding(
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
                  const SizedBox(width: 8),
                  Text(
                    '· $pieces ${pieces == 1 ? 'piece' : 'pieces'}',
                    style: AppTextStyles.smallTextStyle(
                      context,
                    ).copyWith(color: AppColors.greyText),
                  ),
                  const Spacer(),
                  if (showToggle) ...[
                    Text(
                      _expanded ? 'View less' : 'View more ($hiddenCount)',
                      style: AppTextStyles.smallTextStyle(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          for (final group in visibleGroups) ...[
            _ServiceHeader(name: group.serviceName),
            for (final item in group.items) _ItemRow(item: item),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _GroupedServiceLine {
  final String serviceName;
  final List<ServiceItemEntity> items;
  const _GroupedServiceLine({
    required this.serviceName,
    required this.items,
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
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity ?? 0;

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
            child: Text(
              item.itemName ?? 'Item',
              style: AppTextStyles.mediumTextStyle(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'x$qty',
            style: AppTextStyles.mediumTextStyle(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
