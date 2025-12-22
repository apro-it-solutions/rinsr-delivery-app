import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking network connectivity.
abstract class NetworkInfo {
  /// Returns true if device has at least one active connection (WiFi or Mobile).
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    // Check if at least one result is not ConnectivityResult.none
    return results.any((r) => r != ConnectivityResult.none);
  }
}
