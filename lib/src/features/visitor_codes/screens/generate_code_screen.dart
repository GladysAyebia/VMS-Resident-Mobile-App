// lib/src/features/visitor_codes/screens/generate_code_screen.dart

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);

  bool isGenerating = false;
  final DateFormat _dateLabelFormat = DateFormat('MMM d, yyyy');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
    );
    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final initial = start ? startTime : endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter visitor name')),
      );
      return;
    }

    setState(() => isGenerating = true);

    try {
      await provider.generateCode(
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
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _optionalTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CodeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Access Code'),
        centerTitle: true,
        elevation: 0,
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
              'Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            _optionalTextField(
              controller: _nameController,
              icon: Icons.person_outline,
              label: 'Visitor Name',
            ),
            const SizedBox(height: 12),
            _optionalTextField(
              controller: _phoneController,
              icon: Icons.phone_outlined,
              label: 'Visitor Phone (Optional)',
              keyboard: TextInputType.phone,
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
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: (isGenerating || provider.isLoading)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Generate Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
