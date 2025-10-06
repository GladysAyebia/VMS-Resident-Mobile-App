import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VisitorPassScreen extends StatelessWidget {
  final Map<String, dynamic> codeData;

  const VisitorPassScreen({super.key, required this.codeData});

  @override
  Widget build(BuildContext context) {
    final String visitorName = codeData['visitor_name'] ?? 'Unknown';
    final String visitDate = codeData['visit_date'] ?? '';
    final String startTime = codeData['start_time'] ?? '';
    final String endTime = codeData['end_time'] ?? '';
    final String accessCode = codeData['access_code'] ?? 'N/A';
    final String visitorPhone = codeData['visitor_phone'] ?? 'Not provided';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Pass'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              'Visitor: $visitorName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Phone: $visitorPhone'),
            const SizedBox(height: 12),
            Text('Visit Date: $visitDate'),
            const SizedBox(height: 8),
            Text('Time: $startTime - $endTime'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            // ✅ QR Code
            QrImageView(
              data: accessCode,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 20),
            Text(
              'Access Code: $accessCode',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
