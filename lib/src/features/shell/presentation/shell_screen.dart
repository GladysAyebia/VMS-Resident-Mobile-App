
import 'package:flutter/material.dart';
import 'package:vms_resident_app/src/features/home/screens/home_screen.dart';
import 'package:vms_resident_app/src/features/visitor_codes/screens/generate_code_screen.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/profile_screen.dart';
import 'package:vms_resident_app/src/features/visitor_codes/screens/history_screen.dart';
import 'package:vms_resident_app/src/widgets/bottom_nav_bar.dart';

class ShellScreen extends StatefulWidget {
  static const routeName = '/shell';

  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    GenerateCodeScreen(),
    VisitHistoryScreen(),
    ProfileScreen(), // Placeholder    Text('Profile Screen'), // Placeholder    Text('Profile Screen'), // Placeholder        Text('Profile Screen'), // Placeholder    Text('Profile Screen'), // Placeholder    Text('Profile Screen'), //        Text('Profile Screen'), // Placeholder    Text('Profile Screen'), // Placeholder    Text('Profile Screen'), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
