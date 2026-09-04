import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._();

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamController<ConnectivityResult>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  ConnectivityResult _currentStatus = ConnectivityResult.none;

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController?.stream ?? const Stream.empty();

  ConnectivityResult get currentStatus => _currentStatus;

  bool get isConnected => _currentStatus != ConnectivityResult.none;

  bool get isWifiConnected => _currentStatus == ConnectivityResult.wifi;

  bool get isMobileConnected => _currentStatus == ConnectivityResult.mobile;

  Future<void> initialize() async {
    try {
      _connectivityController = StreamController<ConnectivityResult>.broadcast();

      // Get initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _currentStatus = result;

      debugPrint('Initial connectivity: ${_currentStatus.name}');

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
            (ConnectivityResult result) {
          _updateConnectionStatus(result);
        },
        onError: (error) {
          debugPrint('Connectivity stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
      _currentStatus = ConnectivityResult.none;
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (_currentStatus != result) {
      _currentStatus = result;
      debugPrint('Connectivity changed: ${result.name}');
      _connectivityController?.add(result);
    }
  }

  Future<ConnectivityResult> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return result;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return ConnectivityResult.none;
    }
  }

  Future<bool> hasInternetConnection() async {
    final result = await checkConnectivity();
    return result != ConnectivityResult.none;
  }

  String getConnectionTypeString() {
    switch (_currentStatus) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
      default:
        return 'No Connection';
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
    _connectivityController = null;
    _connectivitySubscription = null;
  }
}
