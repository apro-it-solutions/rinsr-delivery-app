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

  static Future<void> launchMaps(BuildContext context, String address) async {
    final query = Uri.encodeComponent(address);
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
}
