import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/core/api_client.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/auth/repositories/auth_repository.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/forgot_password_screen.dart'; 
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/code_provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/visit_history_provider.dart'; 
import 'package:vms_resident_app/src/features/visitor_codes/repositories/visitor_code_repository.dart';
import 'package:vms_resident_app/src/core/navigation/route_observer.dart';

// Changed to async and added the binding initialization
void main() async {
  // CRITICAL: Ensures the Flutter engine is initialized before running any code 
  // that interacts with the native platform (e.g., plugins, custom platform channels).
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient);      
  final codeRepository = VisitorCodeRepository(apiClient); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CodeProvider(codeRepository),
        ),
        ChangeNotifierProvider<HistoryProvider>( 
          create: (_) => HistoryProvider(codeRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMS Resident App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],

      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        ShellScreen.routeName: (_) => const ShellScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(), 
      },
    );
  }
}