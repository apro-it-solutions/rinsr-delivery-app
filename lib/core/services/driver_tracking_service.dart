import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_urls.dart';

/// Pushes the driver's live position to the backend, which re-broadcasts it to
/// the customer's tracking map (socket room `order_tracking_<orderId>`).
///
/// Fire-and-forget telemetry: a failed ping must never disrupt the delivery
/// flow, so errors are swallowed (logged in debug only). The caller throttles
/// how often this is invoked.
class DriverTrackingService {
  final Dio dio;

  DriverTrackingService(this.dio);

  Future<void> sendUpdate({
    required String orderId,
    required double lat,
    required double lng,
    double? headingDeg,
    double? speedKph,
  }) async {
    try {
      await dio.post(
        ApiUrls.driverTrackingUpdate,
        data: {
          'orderId': orderId,
          'lat': lat,
          'lng': lng,
          if (headingDeg != null) 'headingDeg': headingDeg,
          if (speedKph != null) 'speedKph': speedKph,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[TRACKING] driver update failed: $e');
    }
  }
}
