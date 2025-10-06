
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart';
import 'package:vms_resident_app/src/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use dummy data for testing
    _emailController.text = 'user@example.com';
    _passwordController.text = 'Password123!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    await authProvider.login(
                        _emailController.text,
                        _passwordController.text,
                      );

                    if (!mounted) return;

                    if (authProvider.isLoggedIn) {
                      navigator.pushReplacementNamed(ShellScreen.routeName);
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage ?? 'An unknown error occurred.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
               Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
