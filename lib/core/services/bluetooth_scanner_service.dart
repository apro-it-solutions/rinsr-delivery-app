import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Describes why a scan could not start, so the UI can tell the agent what to
/// fix instead of silently showing a blank weight.
enum BleScanFailure { permissionDenied, adapterOff, error }

class BluetoothScannerService {
  StreamSubscription? _subscription;
  final _controller = StreamController<List<int>>.broadcast();
  final _failures = StreamController<BleScanFailure>.broadcast();

  Stream<List<int>> get stream => _controller.stream;

  /// Emits whenever a scan attempt can't proceed (permission denied, Bluetooth
  /// off, etc.) so callers can surface a message to the user.
  Stream<BleScanFailure> get failures => _failures.stream;

  /// Requests the runtime permissions BLE scanning needs. On Android 12+ this is
  /// the "Nearby devices" permission (BLUETOOTH_SCAN/CONNECT); on Android 11 and
  /// below, BLE scanning is gated behind location. flutter_blue_plus does NOT
  /// request these for us, so a denied permission previously failed silently.
  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) {
      // iOS surfaces its own Bluetooth prompt when scanning starts.
      return true;
    }
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // bluetoothScan only exists on Android 12+; on older versions it resolves
    // as granted/restricted and location is what actually matters.
    final scanOk =
        (statuses[Permission.bluetoothScan]?.isGranted ?? false) ||
        (statuses[Permission.locationWhenInUse]?.isGranted ?? false);
    return scanOk;
  }

  Future<void> startScan() async {
    if (!await _ensurePermissions()) {
      if (kDebugMode) {
        debugPrint('[BLE_SCAN] permission not granted');
      }
      _failures.add(BleScanFailure.permissionDenied);
      return;
    }

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
        _failures.add(BleScanFailure.adapterOff);
        return;
      }
    }

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(minutes: 5),
        continuousUpdates: true,
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      // Previously unhandled: startScan throws on denied permission or a busy
      // adapter, which left the weight field blank with no explanation.
      if (kDebugMode) {
        debugPrint('[BLE_SCAN] startScan failed: $e');
      }
      _failures.add(BleScanFailure.error);
      return;
    }

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
    _failures.close();
  }
}
