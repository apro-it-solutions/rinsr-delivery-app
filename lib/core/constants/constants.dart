class AppConstants {
  static const String kToken = 'token';
  static const String kAgentId = 'agent_id';

  // Set once after we've prompted the iOS "Allow Always" location upgrade, so
  // the escalation prompt is shown at most once per install (iOS only surfaces
  // it once anyway). See BackgroundTrackingService._ensurePermissions.
  static const String kAskedAlwaysLocation = 'asked_always_location_permission';

  // ---------------------------------------------------------------------------
  // Store links (force-update fallbacks). The backend response may override
  // these per-platform; these are used when it doesn't.
  // ---------------------------------------------------------------------------

  /// Play Store listing for this app's applicationId (`com.rinsr.delivery`).
  static const String kAndroidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rinsr.delivery';

  /// once the delivery app is live. The iOS store link is dead until this is
  /// set — `kIosStoreUrl` builds off it.
  static const String kAppStoreId = '6763209559';

  /// App Store listing for iOS, derived from [kAppStoreId].
  static String get kIosStoreUrl => 'https://apps.apple.com/app/id$kAppStoreId';
}
