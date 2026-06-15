class AppConstants {
  static const String kToken = 'token';
  static const String kAgentId = 'agent_id';

  // Set once after we've prompted the iOS "Allow Always" location upgrade, so
  // the escalation prompt is shown at most once per install (iOS only surfaces
  // it once anyway). See BackgroundTrackingService._ensurePermissions.
  static const String kAskedAlwaysLocation = 'asked_always_location_permission';
}
