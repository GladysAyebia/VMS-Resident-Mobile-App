import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart'; 
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
static const routeName = '/profile';
const ProfileScreen({super.key});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
// Define Gold color for the theme
static const Color _goldColor = Color(0xFFFFD700);
static const Color _darkGoldColor = Color(0xFFDAA520);

final ImagePicker _picker = ImagePicker();
late TextEditingController _nameController;
File? _imageFile;
bool _isSaving = false;

@override
void initState() {
super.initState();
final authProvider = context.read<AuthProvider>();
final resident = authProvider.resident;
_nameController = TextEditingController(text: resident?.fullName ?? '');
}

@override
void dispose() {
_nameController.dispose();
super.dispose();
}

Future<void> _pickImage() async {
final picked = await _picker.pickImage(source: ImageSource.gallery);
if (picked != null) {
setState(() {
_imageFile = File(picked.path);
});
}
}

Future<void> _updateProfile() async {
final authProvider = context.read<AuthProvider>();
final resident = authProvider.resident;
final token = await authProvider.token;

if (resident == null || token == null) return;
final url = Uri.parse('https://vmsbackend.vercel.app/api/v1/codes/profile');
setState(() => _isSaving = true);

try {
var request = http.MultipartRequest('PUT', url);
request.headers['Authorization'] = 'Bearer $token';
// Split full name into first/last names
final parts = _nameController.text.trim().split(' ');
final firstName = parts.isNotEmpty ? parts.first : '';
final lastName =
parts.length > 1 ? parts.sublist(1).join(' ') : '';
request.fields['first_name'] = firstName;
request.fields['last_name'] = lastName;
request.fields['phone'] = resident.phone ?? '';

if (_imageFile != null) {
request.files.add(await http.MultipartFile.fromPath(
'profile_picture',
_imageFile!.path,
));
}

final response = await request.send();
final responseBody = await response.stream.bytesToString();

if (response.statusCode == 200) {
final updatedData = jsonDecode(responseBody);

// Update AuthProvider to refresh resident data
authProvider.updateResidentProfile(updatedData);

if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('✅ Profile updated successfully!')),
);
} else {
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'❌ Update failed (${response.statusCode}): ${response.reasonPhrase}'),
),
);
}
} catch (e) {

if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('⚠️ Error updating profile: $e')),
);

} finally {
if (mounted) setState(() => _isSaving = false);
}
}

Future<void> _handleLogout() async {
final authProvider = context.read<AuthProvider>();
await authProvider.logout();
if (!mounted) return;
Navigator.of(context).pushNamedAndRemoveUntil(
LoginPage.routeName,
(route) => false,
);
}

@override
Widget build(BuildContext context) {

final authProvider = context.watch<AuthProvider>();
final resident = authProvider.resident;
final String? profileImage = _imageFile != null

? _imageFile!.path
: resident?.profilePicture;
final String userEmail = resident?.email ?? 'No email';
final String userRole = resident?.role ?? 'Resident';

return Scaffold(
backgroundColor: Colors.black, // Black background
appBar: AppBar(
title: const Text('My Profile', style: TextStyle(color: _goldColor)), // Gold title
leading: IconButton(
icon: const Icon(Icons.arrow_back),
onPressed: () {
  
if (Navigator.canPop(context)) { // <--- Safe Pop Logic Unchanged
Navigator.pop(context);
} else {
// Fallback: Navigate to the ShellScreen if no previous page exists
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (_) => const ShellScreen()),
);
}
},
),
backgroundColor: Colors.black, // Black App Bar
foregroundColor: _goldColor, // Gold icons/text
elevation: 0,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
children: [
const SizedBox(height: 20),

// Profile Picture Section
GestureDetector(
onTap: _pickImage,
child: Stack(
children: [
CircleAvatar(
radius: 50,
backgroundColor: Colors.grey[800], // Dark grey fallback background
backgroundImage: _imageFile != null
? FileImage(_imageFile!)
: (profileImage != null
? NetworkImage(profileImage)
: const AssetImage(
'assets/default_avatar.png')
as ImageProvider),
),

Positioned(
bottom: 0,
right: 0,
child: Container(
decoration: const BoxDecoration(
color: _goldColor, // Gold edit button background
shape: BoxShape.circle,
),
padding: const EdgeInsets.all(6),
child: const Icon(
Icons.edit,
color: Colors.black, // Black icon on gold
size: 18,
),
),
),
],
),
),

const SizedBox(height: 20),
// Editable Name Field
TextField(
controller: _nameController,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: _goldColor, // Gold text color
),
decoration: InputDecoration(
border: InputBorder.none,
hintText: 'Enter your full name',
hintStyle: TextStyle(color: _darkGoldColor.withAlpha(128)),
),
),

Text(userEmail, style: TextStyle(color: Colors.grey[400])), // Lighter grey for email
Text('Role: $userRole', style: TextStyle(color: Colors.grey[400])), // Lighter grey for role

const SizedBox(height: 30),
// Save Changes Button
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: _isSaving ? null : _updateProfile,
style: ElevatedButton.styleFrom(
backgroundColor: _goldColor, // Gold button background
foregroundColor: Colors.black, // Black icon/text
padding: const EdgeInsets.symmetric(vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10)),
elevation: 5,
),
icon: _isSaving
? const SizedBox(
height: 20,
width: 20,
child: CircularProgressIndicator(
color: Colors.black, // Black spinner on gold
strokeWidth: 2,
),
)
: const Icon(Icons.save),
label: Text(
_isSaving ? 'Saving...' : 'Save Changes',
style: const TextStyle(fontWeight: FontWeight.bold),
),
),
),

const SizedBox(height: 10),
// Logout Button
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: _handleLogout,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red[800], // Dark red for safety/contrast
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 14),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10)),
elevation: 5,
),
icon: const Icon(Icons.logout),
label: const Text(
'Logout',
style: TextStyle(fontWeight: FontWeight.bold),
),
),
),
],
),
),
);
}
}
