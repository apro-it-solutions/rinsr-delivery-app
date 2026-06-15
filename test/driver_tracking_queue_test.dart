import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rinsr_delivery_partner/core/services/driver_tracking_service.dart';

/// Fake adapter that either accepts POSTs or simulates a dropped network, and
/// counts how many fetches were attempted — lets us assert the queue + flush
/// behaviour without a real socket.
class _FakeAdapter implements HttpClientAdapter {
  bool online = true;
  int fetchCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount++;
    if (!online) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    return ResponseBody.fromString(
      '{"success":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DriverTrackingService queue + flush', () {
    late _FakeAdapter adapter;
    late DriverTrackingService service;

    Future<void> send(double n) =>
        service.sendUpdate(orderId: 'o1', lat: n, lng: n);

    setUp(() {
      adapter = _FakeAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com/'))
        ..httpClientAdapter = adapter;
      service = DriverTrackingService(dio, maxQueued: 5);
    });

    test('posts immediately when online, queues nothing', () async {
      await send(1);
      expect(adapter.fetchCount, 1);
      expect(service.pendingCount, 0);
    });

    test('buffers breadcrumbs while offline, replays them on recovery',
        () async {
      adapter.online = false;
      await send(1);
      await send(2);
      await send(3);
      // Each offline send makes one (failed) attempt on the oldest point.
      expect(adapter.fetchCount, 3);
      expect(service.pendingCount, 3);

      adapter.online = true;
      await send(4); // flushes the 3-deep backlog (oldest-first) + the new fix
      expect(service.pendingCount, 0);
      expect(adapter.fetchCount, 3 + 4);
    });

    test('drops the oldest breadcrumbs beyond maxQueued', () async {
      adapter.online = false;
      for (var i = 0; i < 8; i++) {
        await send(i.toDouble());
      }
      expect(service.pendingCount, 5); // capped, oldest evicted
    });
  });
}
