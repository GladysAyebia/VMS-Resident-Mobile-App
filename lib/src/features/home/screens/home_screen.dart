import 'package:flutter/material.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/screens/generate_code_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final resident = authProvider.resident;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${resident?.firstName}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenerateCodeScreen(),
                  ),
                );
              },
              child: const Text('Generate Visitor Code'),
            ),
          ],
        ),
      ),
    );
  }
}
