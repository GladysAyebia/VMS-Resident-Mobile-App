import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/code_provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/screens/visitor_pass_screen.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart';

class GenerateCodeScreen extends StatefulWidget {
  const GenerateCodeScreen({super.key});

  @override
  State<GenerateCodeScreen> createState() => _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends State<GenerateCodeScreen> {
  // Define Gold color for the theme
  static const Color _goldColor = Color(0xFFFFD700);
  static const Color _darkGoldColor = Color(0xFFDAA520);

  final TextEditingController _nameController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);

  bool isGenerating = false;
  final DateFormat _dateLabelFormat = DateFormat('MMM d, yyyy');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatTimeForApi(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm:ss').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // Apply theme to the date picker dialog
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _goldColor, // Gold header and selected day
              onPrimary: Colors.black, // Text on gold background
              surface: Colors.black, // Dialog background
              onSurface: Colors.white, // Text on dialog background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _goldColor, // Gold buttons (OK, Cancel)
              ),
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final initial = start ? startTime : endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      // Apply theme to the time picker dialog
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _goldColor, // Gold accent and selected time
              onPrimary: Colors.black,
              surface: Colors.black, // Dialog background
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _goldColor,
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.grey[900], // Slightly lighter background for the clock
              hourMinuteColor: WidgetStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? _goldColor : Colors.grey[700]!
              ),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? Colors.black : Colors.white
              ),
              dayPeriodColor: WidgetStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? _goldColor : Colors.grey[700]!
              ),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) => 
                states.contains(WidgetState.selected) ? Colors.black : Colors.white
              ),
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (start) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _onGeneratePressed(CodeProvider provider) async {
    setState(() => isGenerating = true);

    try {
      await provider.generateCode(
        context: context, // 👈 added
        visitorName: _nameController.text.trim(),
        visitDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        startTime: _formatTimeForApi(startTime),
        endTime: _formatTimeForApi(endTime),
      );

      if (!mounted) return;

      final data = provider.generatedCodeData;

      if (data != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VisitorPassScreen(codeData: data),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate code')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating code: $e')),
      );
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  Widget _buildRowField({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[900], // Dark background
          border: Border.all(color: _darkGoldColor), // Gold border
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: _goldColor), // Gold icon
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white), // White text
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: _darkGoldColor), // Dark gold chevron
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white), // White input text
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _goldColor), // Gold icon
        labelText: label,
        labelStyle: const TextStyle(color: _darkGoldColor), // Dark gold label
        enabledBorder: OutlineInputBorder( // Gold border when enabled
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkGoldColor),
        ),
        focusedBorder: OutlineInputBorder( // Bright gold border when focused
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _goldColor, width: 2.0),
        ),
        fillColor: Colors.grey[900], // Dark grey fill
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CodeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        title: const Text('Generate Access Code', style: TextStyle(color: _goldColor)), // Gold title
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black, // Black app bar
        foregroundColor: _goldColor, // Gold back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // fallback to ShellScreen if no previous page exists
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShellScreen()),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Date & Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _goldColor),
            ),
            const SizedBox(height: 8),
            _buildRowField(
              icon: Icons.calendar_today,
              label: _dateLabelFormat.format(selectedDate),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            _buildRowField(
              icon: Icons.access_time,
              label: 'Start Time: ${startTime.format(context)}',
              onTap: () => _pickTime(start: true),
            ),
            const SizedBox(height: 12),
            _buildRowField(
              icon: Icons.access_time_filled,
              label: 'End Time: ${endTime.format(context)}',
              onTap: () => _pickTime(start: false),
            ),
            const SizedBox(height: 20),
            const Text(
              'Visitor Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _goldColor),
            ),
            const SizedBox(height: 8),
            _textField(
              controller: _nameController,
              icon: Icons.person_outline,
              label: 'Visitor Name (Optional)',
            ),
            const SizedBox(height: 16),
            const Text(
              'Code will be valid only during the specified time period.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (isGenerating || provider.isLoading)
                  ? null
                  : () => _onGeneratePressed(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor, // Gold button background
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: (isGenerating || provider.isLoading)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black, // Black spinner on gold
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'GENERATE CODE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text on gold
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
