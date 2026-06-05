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
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  // True between startScan() and stopScan(); lets the adapter-state listener
  // know whether a scan should (re)start when Bluetooth comes on.
  bool _scanRequested = false;
  // Reentrancy guard: the adapter can flap (off/on/on) faster than a scan
  // start completes; only one _beginScan may run at a time.
  bool _startingScan = false;
  final _controller = StreamController<List<int>>.broadcast();
  final _failures = StreamController<BleScanFailure?>.broadcast();

  Stream<List<int>> get stream => _controller.stream;

  /// Emits whenever a scan attempt can't proceed (permission denied, Bluetooth
  /// off, etc.) so callers can surface a message to the user. Emits `null`
  /// when scanning recovers (e.g. the agent turned Bluetooth back on) so the
  /// message can be cleared.
  Stream<BleScanFailure?> get failures => _failures.stream;

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
    _scanRequested = true;

    if (!await _ensurePermissions()) {
      if (kDebugMode) {
        debugPrint('[BLE_SCAN] permission not granted');
      }
      _failures.add(BleScanFailure.permissionDenied);
      return;
    }

    // Drive the scan off the adapter state for the life of this request.
    // Client repro: agent reaches the pickup form with Bluetooth OFF, then
    // turns Bluetooth + the scale on while already on the screen. The old
    // code waited 10s for the adapter and then gave up for good; now the
    // scan starts (or restarts) automatically whenever the adapter comes on.
    // This also covers iOS's transient CBManagerStateUnknown at launch.
    await _adapterSubscription?.cancel();
    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!_scanRequested) return;
      if (state == BluetoothAdapterState.on) {
        _beginScan();
      } else if (state == BluetoothAdapterState.off) {
        if (kDebugMode) {
          debugPrint('[BLE_SCAN] adapter off — waiting for it to come on');
        }
        _failures.add(BleScanFailure.adapterOff);
      }
      // Transient states (unknown / turningOn) — keep waiting silently.
    });

    // The platform scan has a 5-minute timeout; if it expires while the agent
    // is still on the weighing screen (e.g. scale switched on late), restart
    // it so readings resume without leaving the screen.
    await _isScanningSubscription?.cancel();
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      if (scanning || !_scanRequested || _startingScan) return;
      // Adapter-off is handled (and retried) by the adapter listener above.
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) return;
      if (kDebugMode) {
        debugPrint('[BLE_SCAN] scan ended while still needed — restarting');
      }
      _beginScan();
    });
  }

  Future<void> _beginScan() async {
    if (_startingScan) return;
    _startingScan = true;
    try {
      // Don't skip when isScanningNow is true: after Bluetooth is toggled off
      // mid-scan the platform scan is dead but the plugin flag can stay stale,
      // which used to make this an early return and the scale never read
      // again. Stopping a stale/live scan first is always safe.
      if (FlutterBluePlus.isScanningNow) {
        try {
          await FlutterBluePlus.stopScan();
        } catch (_) {
          // Stale flag with no real scan — nothing to stop.
        }
      }

      // Right after the adapter reports "on" the platform stack may not be
      // ready yet, so retry briefly instead of giving up on one throw.
      for (var attempt = 1; ; attempt++) {
        if (!_scanRequested) return;
        try {
          await FlutterBluePlus.startScan(
            timeout: const Duration(minutes: 5),
            continuousUpdates: true,
            androidScanMode: AndroidScanMode.lowLatency,
          );
          break;
        } catch (e) {
          // Previously unhandled: startScan throws on denied permission or a
          // busy adapter, which left the weight field blank unexplained.
          if (kDebugMode) {
            debugPrint('[BLE_SCAN] startScan failed (attempt $attempt): $e');
          }
          if (attempt >= 3) {
            _failures.add(BleScanFailure.error);
            return;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      // Scanning is live — clear any earlier "Bluetooth is off" message.
      _failures.add(null);

      await _attachResultsListener();
    } finally {
      _startingScan = false;
    }
  }

  Future<void> _attachResultsListener() async {
    await _subscription?.cancel();
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
    _scanRequested = false;
    _adapterSubscription?.cancel();
    _adapterSubscription = null;
    _isScanningSubscription?.cancel();
    _isScanningSubscription = null;
    _subscription?.cancel();
    // Swallow errors — stopScan can throw if the adapter is already off.
    FlutterBluePlus.stopScan().catchError((_) {});
  }

  void dispose() {
    stopScan();
    _controller.close();
    _failures.close();
  }
}
