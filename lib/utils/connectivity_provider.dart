import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityStatus extends ChangeNotifier {
  ConnectivityStatus() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result;
      notifyListeners();
    });
  }

  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  Future<ConnectivityResult> getConnectionStatus() async {
    _connectionStatus = await Connectivity().checkConnectivity();
    return _connectionStatus;
  }

  bool get isConnected => _connectionStatus != ConnectivityResult.none;
}
