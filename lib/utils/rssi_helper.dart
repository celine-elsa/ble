import 'package:flutter/material.dart';
import 'dart:math' as math;

class RssiHelper {
  static Color getRssiColor(int rssi) {
    if (rssi > -60) return Colors.green;
    if (rssi > -75) return Colors.orange;
    return Colors.red;
  }

  static IconData getRssiIcon(int rssi) {
    if (rssi > -60) return Icons.signal_cellular_alt;
    if (rssi > -75) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }

  static String getSignalStrength(int rssi) {
    if (rssi > -60) return "Excellent";
    if (rssi > -75) return "Good";
    return "Weak";
  }

  static String calculateDistance(int rssi, {int txPower = -59}) {
    const n = 2.0;
    final distance = math.pow(10, (txPower - rssi) / (10 * n));

    if (distance < 1) {
      return "${(distance * 100).toStringAsFixed(0)} cm";
    } else if (distance < 10) {
      return "${distance.toStringAsFixed(1)} m";
    } else {
      return "${distance.toStringAsFixed(0)} m";
    }
  }
}