import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// iOS-only nudge shown on an en-route order when the app has only
/// "While Using" location permission.
///
/// Background tracking on iOS (no foreground service — a background-capable
/// geolocator stream) is only reliable with **Always** authorization. iOS will
/// not re-prompt for the upgrade on demand, so the agent has to flip it in
/// Settings. This banner detects the gap and gives them a one-tap route there,
/// then re-checks when the app returns to the foreground so it clears itself
/// once Always is granted.
///
/// Renders nothing on Android, off iOS, when the order isn't en route, or when
/// permission is already Always — so it's safe to drop into the screen
/// unconditionally for en-route orders.
class IosAlwaysLocationBanner extends StatefulWidget {
  /// Whether the current order is heading to the customer (background tracking
  /// territory). The banner only matters then.
  final bool isEnRoute;

  const IosAlwaysLocationBanner({super.key, required this.isEnRoute});

  @override
  State<IosAlwaysLocationBanner> createState() =>
      _IosAlwaysLocationBannerState();
}

class _IosAlwaysLocationBannerState extends State<IosAlwaysLocationBanner>
    with WidgetsBindingObserver {
  LocationPermission? _permission;

  bool get _isApplicable => Platform.isIOS && widget.isEnRoute;

  @override
  void initState() {
    super.initState();
    if (_isApplicable) {
      WidgetsBinding.instance.addObserver(this);
      _refresh();
    }
  }

  @override
  void didUpdateWidget(IosAlwaysLocationBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // En-route status can flip while the screen is open (status change). Start
    // or stop observing accordingly and re-check.
    if (widget.isEnRoute != oldWidget.isEnRoute && Platform.isIOS) {
      if (widget.isEnRoute) {
        WidgetsBinding.instance.addObserver(this);
        _refresh();
      } else {
        WidgetsBinding.instance.removeObserver(this);
      }
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check when returning from Settings (or any background trip) so the
    // banner disappears the moment the agent grants Always.
    if (state == AppLifecycleState.resumed && _isApplicable) _refresh();
  }

  Future<void> _refresh() async {
    final permission = await Geolocator.checkPermission();
    if (mounted) setState(() => _permission = permission);
  }

  @override
  Widget build(BuildContext context) {
    // Only "While Using" needs the nudge: Always is fine, and a full denial is
    // handled by the request flow elsewhere.
    if (!_isApplicable || _permission != LocationPermission.whileInUse) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Color(0xFFEF6C00)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable Always-on Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Live tracking pauses when your screen locks. Set location '
                  'access to "Always" so the customer can follow your delivery.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Geolocator.openAppSettings(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text('Open Settings'),
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
