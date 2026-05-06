import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<void> requestBluetoothPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }
}