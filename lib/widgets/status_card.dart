import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool isScanning;
  final int deviceCount;
  final VoidCallback onPressed;

  const StatusCard({
    super.key,
    required this.isScanning,
    required this.deviceCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isScanning ? "Scanning..." : "Ready to Scan",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$deviceCount device${deviceCount != 1 ? 's' : ''} found",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(isScanning ? Icons.refresh : Icons.play_arrow),
            label: Text(isScanning ? "Refresh" : "Start"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}