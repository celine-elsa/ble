import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your actual API endpoint
  static const String baseUrl = 'http://192.168.69.248:3000';
  
  // Send beacon data to endpoint
  static Future<Map<String, dynamic>> sendBeaconData({
    required String beaconName,
    required String beaconId,
    required String studentId,
    required String deviceId,
    String? rssi,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/attendance'); // Adjust endpoint path as needed
      
      final Map<String, dynamic> payload = {
        'student_id': studentId,
        'device_id': deviceId,
        'beacon_id': beaconId,
        'rssi': int.parse(rssi!),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Add optional fields
      if (rssi != null) {
        payload['rssi'] = rssi;
      }
      
      if (additionalData != null) {
        payload.addAll(additionalData);
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add any authentication headers here if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'Beacon data sent successfully',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to send data: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending data',
        'error': e.toString(),
      };
    }
  }

  // Optional: Get beacon data from endpoint
  static Future<Map<String, dynamic>> getBeaconData(String beaconId) async {
    try {
      final url = Uri.parse('$baseUrl/beacons/$beaconId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch data: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching data',
        'error': e.toString(),
      };
    }
  }

  static Future<void> registerDevice({
    required String studentId,
    required String deviceId,
    required String fcmToken,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/register-device'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "student_id": studentId,
        "device_id": deviceId,
        "fcm_token": fcmToken,
      }),
    );
  }
}