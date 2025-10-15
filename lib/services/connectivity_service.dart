import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      if (kDebugMode) {
        debugPrint(
          'Connectivity status: $connectivityResult, Connected: $isConnected',
        );
      }

      return isConnected;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  Future<String> getConnectionType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
        return 'Bluetooth';
      } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
        return 'VPN';
      } else if (connectivityResult.contains(ConnectivityResult.other)) {
        return 'Other';
      } else if (connectivityResult.contains(ConnectivityResult.none)) {
        return 'No Connection';
      }
      return 'Unknown';
    } catch (e) {
      debugPrint('Error getting connection type: $e');
      return 'Unknown';
    }
  }

  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      final isConnected = !result.contains(ConnectivityResult.none);
      if (kDebugMode) {
        debugPrint('Connectivity changed: $result, Connected: $isConnected');
      }
      return isConnected;
    });
  }
}
