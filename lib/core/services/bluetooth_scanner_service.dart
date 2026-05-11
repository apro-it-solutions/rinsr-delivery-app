import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScannerService {
  StreamSubscription? _subscription;
  final _controller = StreamController<List<int>>.broadcast();

  Stream<List<int>> get stream => _controller.stream;

  Future<void> startScan() async {
    // iOS: CoreBluetooth reports CBManagerStateUnknown for ~1-2s after the
    // app launches (and after the permission prompt). Wait for the adapter
    // to actually be on before scanning, otherwise startScan throws.
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.adapterState
            .firstWhere((s) => s == BluetoothAdapterState.on)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BLE_SCAN] adapter never reached "on": $e');
        }
        return;
      }
    }

    await FlutterBluePlus.startScan(
      timeout: const Duration(minutes: 5),
      continuousUpdates: true,
    );

    _subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final adv = r.advertisementData;

        final name = adv.advName.isNotEmpty ? adv.advName : r.device.platformName;
        if (name.contains('IF') && adv.manufacturerData.isNotEmpty) {
          adv.manufacturerData.forEach((_, bytes) {
            if (kDebugMode) {
              final hex =
                  bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
              debugPrint('[BLE_SCAN] $name bytes=$hex');
            }
            _controller.add(bytes);
          });
        }
      }
    });
  }

  void stopScan() {
    _subscription?.cancel();
    FlutterBluePlus.stopScan();
  }

  void dispose() {
    stopScan();
    _controller.close();
  }
}
