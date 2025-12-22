import 'package:flutter/material.dart';

class OrderLocationStatus extends StatelessWidget {
  final bool isLocationLoading;
  final double? distanceInMeters;
  final String? locationError;
  final bool isEnabled;

  const OrderLocationStatus({
    super.key,
    required this.isLocationLoading,
    required this.distanceInMeters,
    required this.locationError,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocationLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Verifying location...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (locationError != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                locationError!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (distanceInMeters != null) {
      final distanceKm = (distanceInMeters! / 1000).toStringAsFixed(2);
      final color = isEnabled ? Colors.green : Colors.orange;
      final text = 'Distance: ${distanceKm}km';

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isEnabled ? Icons.check_circle_outline : Icons.near_me,
              size: 20,
              color: color.shade700,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: color.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isEnabled) ...[
              const Spacer(),
              Text(
                'Target: <50m',
                style: TextStyle(
                  color: color.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
