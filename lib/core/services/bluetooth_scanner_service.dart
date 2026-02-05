import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScannerService {
  StreamSubscription? _subscription;
  final _controller = StreamController<List<int>>.broadcast();

  Stream<List<int>> get stream => _controller.stream;

  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(minutes: 5));

    _subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final adv = r.advertisementData;

        if (adv.advName.contains('IF') && adv.manufacturerData.isNotEmpty) {
          adv.manufacturerData.forEach((_, bytes) {
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
