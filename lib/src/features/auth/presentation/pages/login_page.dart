import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = 'auth/login';

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
    _emailController.text = 'jane.resident1@example.com';
    _passwordController.text = 'Password123A';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔹 Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // 🔹 Title
              const Text(
                'Resident Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // 🔹 Email Field
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.amber),
                  filled: true,
                  fillColor: Colors.white10,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.amberAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔹 Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.amber),
                  filled: true,
                  fillColor: Colors.white10,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.amberAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🔹 Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authProvider = context.read<AuthProvider>();
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    await authProvider.login(
                      _emailController.text,
                      _passwordController.text,
                    );

                    if (!mounted) return;

                    if (authProvider.isLoggedInState) {
                      navigator.pushReplacementNamed(ShellScreen.routeName);
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.errorMessage ??
                                'An unknown error occurred.',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 Forgot Password
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(ForgotPasswordScreen.routeName);
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Loading Indicator
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isLoading) {
                    return const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Colors.amber,
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
