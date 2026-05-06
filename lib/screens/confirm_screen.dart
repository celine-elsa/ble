import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  Future<void> _confirm() async {
    final deviceId = await DeviceService.getDeviceId();
    const studentId = "B222270027";

    await ApiService.sendBeaconData(
      beaconName: "N/A",
      beaconId: "ROOM101",
      studentId: studentId,
      deviceId: deviceId,
      rssi: "0",
      additionalData: {
        "type": "re_check",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Check")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _confirm();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Attendance confirmed")),
            );
          },
          child: const Text("Confirm Attendance"),
        ),
      ),
    );
  }
}