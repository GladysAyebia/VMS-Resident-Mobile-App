import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/login_page.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final resident = authProvider.resident;

    final String userName = resident?.fullName ?? 'Loading...';
    final String userEmail = resident?.email ?? 'No email';
    final String userRole = resident?.role ?? 'Resident';
    final String? profileImage = resident?.profilePicture;
    const bool notificationsEnabled = true; // Replace if you add a real field

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('EstateGuard'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text('My Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage)
                        : null,
                    backgroundColor: Colors.grey,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Role: $userRole',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildSectionHeader(context, 'Account Settings'),
            _buildSettingTile(
              title: 'Username:',
              value: userName,
              context: context,
              showDivider: true,
            ),
            _buildSettingTile(
              title: 'Password:',
              value: '••••••••',
              context: context,
              showDivider: true,
            ),
            _buildToggleSetting(
              title: 'Notifications',
              value: notificationsEnabled,
              onChanged: (bool newValue) {
                // TODO: Implement toggle logic
              },
              showDivider: true,
            ),
            _buildLanguageSetting(
              title: 'Language',
              value: 'English',
              context: context,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Logout',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          LoginPage.routeName, (Route<dynamic> route) => false);
    }
  }

  // -------------------------
  // Helper Widgets
  // -------------------------
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String value,
    required BuildContext context,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Row(
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Edit/change functionality
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 24, endIndent: 24),
      ],
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 24, endIndent: 24),
      ],
    );
  }

  Widget _buildLanguageSetting({
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: const Icon(Icons.arrow_drop_down),
                items: <String>['English', 'Spanish', 'French']
                    .map((val) => DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, style: const TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  // TODO: Implement language change logic
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
