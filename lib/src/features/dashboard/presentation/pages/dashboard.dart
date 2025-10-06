
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';

class Dashboard extends StatelessWidget {
  static const routeName = '/dashboard';

  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final resident = authProvider.resident;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${resident?.firstName} ${resident?.lastName}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text('Email: ${resident?.email}'),
            Text('Phone: ${resident?.phone}'),
            Text('Home ID: ${resident?.homeId}'),
            Text('Role: ${resident?.role}'),
            Text('Status: ${resident?.status}'),
          ],
        ),
      ),
    );
  }
}
