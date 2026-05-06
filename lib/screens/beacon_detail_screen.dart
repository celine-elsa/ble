import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/rssi_helper.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'dart:math' as math;

class BeaconDetailScreen extends StatefulWidget {
  final ScanResult scanResult;

  const BeaconDetailScreen({
    super.key,
    required this.scanResult,
  });

  @override
  State<BeaconDetailScreen> createState() => _BeaconDetailScreenState();
}

class _BeaconDetailScreenState extends State<BeaconDetailScreen> {
  bool _isSending = false;

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendBeaconToApi() async {
    setState(() {
      _isSending = true;
    });

    final device = widget.scanResult.device;
    final beaconName = device.name.isNotEmpty ? device.name : "Unknown Device";
    final beaconId = device.id.toString();

    // Prepare additional data to send
    final additionalData = {
      'rssi': widget.scanResult.rssi.toString(),
      'signal_strength': RssiHelper.getSignalStrength(widget.scanResult.rssi),
      'estimated_distance': RssiHelper.calculateDistance(widget.scanResult.rssi),
      'platform_name': device.platformName,
      'connectable': widget.scanResult.advertisementData.connectable,
    };

    // Add service UUIDs if available
    if (widget.scanResult.advertisementData.serviceUuids.isNotEmpty) {
      additionalData['service_uuids'] = widget.scanResult.advertisementData.serviceUuids
          .map((uuid) => uuid.toString())
          .toList();
    }

    // Add manufacturer data if available
    if (widget.scanResult.advertisementData.manufacturerData.isNotEmpty) {
      additionalData['manufacturer_data'] = widget.scanResult.advertisementData.manufacturerData
          .map((key, value) => MapEntry(
                key.toString(),
                value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
              ));
    }

    final deviceId = await DeviceService.getDeviceId();
    final studentId = "B222270027"; // түр hardcode

    final result = await ApiService.sendBeaconData(
      beaconName: beaconName,
      beaconId: beaconId,
      studentId: studentId,
      deviceId: deviceId,
      rssi: widget.scanResult.rssi.toString(),
      additionalData: {
        "type": "check_in",
      },
    );

    setState(() {
      _isSending = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(result['message'] ?? 'Data sent successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(result['message'] ?? 'Failed to send data'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _sendBeaconToApi,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.scanResult.device;
    final rssiColor = RssiHelper.getRssiColor(widget.scanResult.rssi);
    final signalStrength = RssiHelper.getSignalStrength(widget.scanResult.rssi);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Beacon Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card with Signal Strength
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rssiColor, rssiColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: rssiColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    RssiHelper.getRssiIcon(widget.scanResult.rssi),
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    device.name.isNotEmpty ? device.name : "Unknown Device",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${widget.scanResult.rssi} dBm • $signalStrength",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Send to API Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendBeaconToApi,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload, size: 24),
                label: Text(
                  _isSending ? 'Sending...' : 'Send to API',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Device Information Section
            _buildSection(
              context,
              title: "Device Information",
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.fingerprint,
                  label: "Device ID",
                  value: device.id.toString(),
                  onTap: () => _copyToClipboard(
                    context,
                    device.id.toString(),
                    'Device ID',
                  ),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.label,
                  label: "Device Name",
                  value: device.name.isNotEmpty ? device.name : "Not available",
                  onTap: device.name.isNotEmpty
                      ? () => _copyToClipboard(context, device.name, 'Device Name')
                      : null,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.devices,
                  label: "Platform Name",
                  value: device.platformName.isNotEmpty
                      ? device.platformName
                      : "Not available",
                ),
              ],
            ),

            // Signal Information Section
            _buildSection(
              context,
              title: "Signal Information",
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.signal_cellular_alt,
                  label: "RSSI",
                  value: "${widget.scanResult.rssi} dBm",
                  trailing: _buildSignalBar(widget.scanResult.rssi),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.speed,
                  label: "Signal Strength",
                  value: signalStrength,
                  valueColor: rssiColor,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.timeline,
                  label: "Estimated Distance",
                  value: RssiHelper.calculateDistance(widget.scanResult.rssi),
                ),
              ],
            ),

            // Advertisement Data Section
            if (widget.scanResult.advertisementData.serviceUuids.isNotEmpty ||
                widget.scanResult.advertisementData.manufacturerData.isNotEmpty)
              _buildSection(
                context,
                title: "Advertisement Data",
                children: [
                  if (widget.scanResult.advertisementData.serviceUuids.isNotEmpty)
                    _buildInfoTile(
                      context,
                      icon: Icons.list_alt,
                      label: "Service UUIDs",
                      value: widget.scanResult.advertisementData.serviceUuids.length.toString(),
                      subtitle: widget.scanResult.advertisementData.serviceUuids
                          .map((uuid) => uuid.toString())
                          .join('\n'),
                    ),
                  if (widget.scanResult.advertisementData.manufacturerData.isNotEmpty)
                    _buildInfoTile(
                      context,
                      icon: Icons.factory,
                      label: "Manufacturer Data",
                      value: widget.scanResult.advertisementData.manufacturerData.keys
                          .map((key) => "0x${key.toRadixString(16).toUpperCase()}")
                          .join(', '),
                    ),
                  _buildInfoTile(
                    context,
                    icon: Icons.visibility,
                    label: "Connectable",
                    value: widget.scanResult.advertisementData.connectable ? "Yes" : "No",
                  ),
                  _buildInfoTile(
                    context,
                    icon: Icons.power,
                    label: "TX Power Level",
                    value: widget.scanResult.advertisementData.txPowerLevel != null
                        ? "${widget.scanResult.advertisementData.txPowerLevel} dBm"
                        : "Not available",
                  ),
                ],
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Widget? trailing,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalBar(int rssi) {
    final percentage = ((rssi + 100) / 70 * 100).clamp(0, 100).toInt();
    final color = RssiHelper.getRssiColor(rssi);

    return SizedBox(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$percentage%",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}