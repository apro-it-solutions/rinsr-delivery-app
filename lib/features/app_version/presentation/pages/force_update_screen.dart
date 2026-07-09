import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_alerts.dart';
import '../../../../core/widgets/continue_button.dart';
import '../../domain/entities/app_version_entity.dart';

/// Non-dismissible full-screen gate shown when the running version is below the
/// server's `min_supported_version`. The only action opens the store; the
/// system back button is blocked.
class ForceUpdateScreen extends StatelessWidget {
  final AppVersionEntity versionInfo;

  const ForceUpdateScreen({super.key, required this.versionInfo});

  Future<void> _openStore(BuildContext context) async {
    final url = Platform.isIOS
        ? (versionInfo.iosStoreUrl ?? AppConstants.kIosStoreUrl)
        : (versionInfo.androidStoreUrl ?? AppConstants.kAndroidStoreUrl);

    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        AppAlerts.showErrorSnackBar(
          context: context,
          message: 'Could not open the store. Please update manually.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.system_update,
                  size: 88,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 28),
                Text(
                  'Update Required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.headerTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A new version of the app is available and required to '
                  'continue. Please update to the latest version.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyTextColor,
                  ),
                ),
                const SizedBox(height: 36),
                ContinueButton(
                  text: 'Update Now',
                  onPressed: () => _openStore(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
