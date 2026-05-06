import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  final Map<String, ScanResult> _devices = {};
  StreamSubscription? _scanSubscription;
  Timer? _autoRefreshTimer;
  bool _isScanning = false;

  Map<String, ScanResult> get devices => _devices;
  bool get isScanning => _isScanning;

  void startContinuousScan(Function() onUpdate) {
    if (_isScanning) return;

    _isScanning = true;
    _devices.clear();

    // Start the scan
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if( r.rssi > -80 )
          _devices[r.device.id.toString()] = r;
      }
      onUpdate();
    });

    // Auto-refresh: restart scan every 4 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      FlutterBluePlus.stopScan();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isScanning) {
          FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
        }
      });
    });
  }

  void stopScan() {
    _isScanning = false;
    _scanSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    FlutterBluePlus.stopScan();
  }

  void refreshScan(Function() onUpdate) {
    stopScan();
    Future.delayed(const Duration(milliseconds: 200), () {
      startContinuousScan(onUpdate);
    });
  }

  List<ScanResult> getSortedDevices() {
    return _devices.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  void dispose() {
    stopScan();
  }
}