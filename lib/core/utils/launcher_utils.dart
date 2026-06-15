import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_alerts.dart';

class LauncherUtils {
  static Future<void> launchPhone(
    BuildContext context,
    String phoneNumber,
  ) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri);
      }
    } catch (_) {
      if (context.mounted) {
        AppAlerts.showErrorSnackBar(
          context: context,
          message: 'Could not launch dialer',
        );
      }
    }
  }

  /// Opens Google Maps at the destination. Prefers the backend's exact
  /// "lat,lng" [coordinates] when present — geocoding the free-text [address]
  /// can land kilometres off for Indian addresses (same root cause as the
  /// distance/ETA bug). Falls back to an address search when coordinates are
  /// absent or malformed.
  static Future<void> launchMaps(
    BuildContext context,
    String address, {
    String? coordinates,
  }) async {
    final latLng = _normalizeLatLng(coordinates);
    final query = Uri.encodeComponent(latLng ?? address);
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppAlerts.showErrorSnackBar(
            context: context,
            message: 'Could not launch maps',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppAlerts.showErrorSnackBar(
          context: context,
          message: 'Error launching maps',
        );
      }
    }
  }

  /// Returns a clean "lat,lng" string when [raw] holds two parseable numbers,
  /// otherwise null. Trims whitespace so Google Maps treats it as a coordinate
  /// query rather than a free-text search.
  static String? _normalizeLatLng(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return '$lat,$lng';
  }
}
