import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../utils/permissions_helper.dart';
import '../widgets/status_card.dart';
import '../widgets/device_list_item.dart';
import '../services/notification_service.dart';
import '../services/device_service.dart';
import '../services/api_service.dart';
import 'confirm_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class BeaconScannerScreen extends StatefulWidget {
  const BeaconScannerScreen({super.key});

  @override
  State<BeaconScannerScreen> createState() => _BeaconScannerScreenState();
}

class _BeaconScannerScreenState extends State<BeaconScannerScreen> {
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
    PermissionsHelper.requestBluetoothPermissions();

    _setupDevice();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConfirmScreen()),
        );
      });
    });
  }

  void _setupDevice() async {
    final token = await NotificationService.initFCM();
    final deviceId = await DeviceService.getDeviceId();
    final studentId = "B222270027";

    if (token != null) {
    await ApiService.registerDevice(
      studentId: studentId,
      deviceId: deviceId,
      fcmToken: token,
      );
    }

    await ApiService.registerDevice(
      studentId: studentId,
      deviceId: deviceId,
      fcmToken: token!,
    );
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  void _handleButtonPress() {
    if (_bluetoothService.isScanning) {
      _bluetoothService.refreshScan(_updateUI);
    } else {
      _bluetoothService.startContinuousScan(_updateUI);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDevices = _bluetoothService.getSortedDevices();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "BLE Beacon Scanner",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_bluetoothService.isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          StatusCard(
            isScanning: _bluetoothService.isScanning,
            deviceCount: _bluetoothService.devices.length,
            onPressed: _handleButtonPress,
          ),
          Expanded(
            child: _bluetoothService.devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _bluetoothService.isScanning
                              ? "Searching for devices..."
                              : "Press Start to scan for beacons",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedDevices.length,
                    itemBuilder: (context, index) {
                      return DeviceListItem(device: sortedDevices[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _bluetoothService.isScanning
          ? FloatingActionButton(
              onPressed: () {
                _bluetoothService.stopScan();
                _updateUI();
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            )
          : null,
    );
  }
}