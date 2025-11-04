import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // added font awesome for better ux


class VisitorPassScreen extends StatefulWidget {
  final Map<String, dynamic> codeData;
  const VisitorPassScreen({super.key, required this.codeData});

  @override
  State<VisitorPassScreen> createState() => _VisitorPassScreenState();
}


class _VisitorPassScreenState extends State<VisitorPassScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  // State variables populated in initState to avoid recalculation in build
  late String _formattedDate;
  late String _visitorName;
  late String _startTime;
  late String _endTime;
  late String _accessCode;
  late String _passDataForQr;

  // Define Gold color for the theme
  static const Color _goldColor = Color(0xFFFFD700); // Standard Gold color
  static const Color _darkGoldColor = Color(0xFFDAA520); // Darker Gold for accents

  @override
  void initState() {
    super.initState();
    // 1. Extract and process data once
    final String visitDate = widget.codeData['visit_date'] ?? '';
    _visitorName = widget.codeData['visitor_name'] ?? 'Unknown Visitor';
    _startTime = widget.codeData['start_time'] ?? '';
    _endTime = widget.codeData['end_time'] ?? '';
    _accessCode =
        widget.codeData['access_code'] ?? widget.codeData['code'] ?? 'N/A';
    _passDataForQr = 'EG|$_accessCode';


    // 2. Perform date formatting outside of the build method
    try {
      _formattedDate =
          DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(visitDate));
    } catch (e) {
      // Fallback in case date parsing fails (e.g., if it's already a string like "Today")
      _formattedDate = visitDate;
      debugPrint('Error parsing date, using raw value: $e');
    }
  }


  /// Handles taking a screenshot and sharing the pass details and image.
  Future<void> _sharePass(String platform) async {
    // 1. Take a screenshot
    final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10)); // Added delay for stability
    if (image == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture pass image.')));
      }
      return;
    }


    // 2. Save screenshot to a temporary directory
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/visitor_pass.png';
    final file = File(imagePath);
    await file.writeAsBytes(image);


    // 3. Construct sharing message
    final messageText =
        'Visitor Pass for $_visitorName\nCode: $_accessCode\nDate: $_formattedDate\nTime: $_startTime - $_endTime\nUse this pass at the estate gate.';


    try {
      // Handle Copy Link separately
      if (platform == 'Copy Link') {
        await Clipboard.setData(ClipboardData(text: messageText));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pass details copied to clipboard!')),
        );
        return;
      }


      // Share with share_plus (for WhatsApp, Email, etc.)
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: messageText,
        subject: 'Woezor Smart Security Visitor Pass',
      );


      // Clean up the temporary file (optional but good practice)
      // await file.delete();


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shared via $platform')),
      );
    } catch (e) {
      debugPrint('Error sharing pass: $e');
      if (!mounted) return;
      // Provide user-friendly feedback on failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Failed to share pass. Check permissions or try another app.')),
      );
    }
  }


  /// Builds a clickable sharing button column.
  Widget _buildShareButton(
      BuildContext context, IconData icon, String platform, Color color) {
    return Column(
      children: [
        InkWell(
          onTap: () => _sharePass(platform),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade800, width: 1.5), // Darker border
              color: Colors.black, // Background of the circle button
            ),
            // Using FaIcon for Font Awesome icons
            child: FaIcon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 5),
        Text(platform, style: const TextStyle(fontSize: 12, color: _goldColor)), // Gold text
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Overall black background
      appBar: AppBar(
        title: const Text('Visitor Pass', style: TextStyle(color: _goldColor)), // Gold title
        centerTitle: true,
        backgroundColor: Colors.black, // Black app bar
        foregroundColor: _goldColor, // Gold foreground elements
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Screenshot(
            controller: _screenshotController,
            child: Card(
              color: Colors.grey[900], // Dark grey card background
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 10, // Increased elevation for a nicer look
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'WOEZOR SMART SECURITY',
                      style: TextStyle(
                          fontSize: 18,
                          color: _goldColor, // Gold color
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    QrImageView(
                      data: _passDataForQr,
                      version: QrVersions.auto,
                      size: 220.0, // Slightly larger QR code
                      backgroundColor: Colors.white, // QR background remains white for readability
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black, // QR eyes remain black
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black, // QR data modules remain black
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Use a monospace font for the code for easy reading (optional)
                    Text(
                      _accessCode,
                      style: const TextStyle(
                        fontSize: 52, // Larger code text
                        fontWeight: FontWeight.w900,
                        color: _goldColor, // Gold color
                        letterSpacing: 2.0,
                        fontFamily: 'RobotoMono', // Assuming a monospace font is available
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'VALID: $_formattedDate, $_startTime - $_endTime',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white70), // Lighter white for contrast
                    ),
                    const SizedBox(height: 25),
                    const Divider(thickness: 1.2, color: _goldColor), // Gold divider
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VISITOR: $_visitorName',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _goldColor)), // Gold color
                            const SizedBox(height: 5),
                            Text(
  'RESIDENT: ${widget.codeData['resident']?['name'] ?? 'Unknown Resident'}',
  style: const TextStyle(fontSize: 16, color: Colors.grey),
),
Text(
  'HOME: ${widget.codeData['resident']?['home'] ?? 'N/A'}',
  style: const TextStyle(fontSize: 16, color: Colors.grey),
),
 // Grey for secondary info
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Share buttons using FontAwesomeIcons for production UX
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                    context, FontAwesomeIcons.whatsapp, 'WhatsApp', Colors.green), // WhatsApp icon color
                _buildShareButton(
                    context, FontAwesomeIcons.solidEnvelope, 'Email', _goldColor), // Gold icon color
                _buildShareButton(
                    context, FontAwesomeIcons.solidCommentDots, 'SMS', Colors.deepPurple), // SMS icon color
                _buildShareButton(
                    context, Icons.link, 'Copy Link', _darkGoldColor), // Darker gold for contrast
              ],
            ),
            const SizedBox(height: 20),
            // Done button
            SizedBox(
              width: double.infinity, // Full width button
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.black), // Black icon
                label: const Text('DONE',
                    style: TextStyle(
                        color: Colors.black, // Black text
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _goldColor, // Gold button background
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
