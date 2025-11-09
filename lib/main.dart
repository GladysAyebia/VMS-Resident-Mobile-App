import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/core/api_client.dart';
import 'package:vms_resident_app/src/features/auth/providers/auth_provider.dart';
import 'package:vms_resident_app/src/features/auth/repositories/auth_repository.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/login_page.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:vms_resident_app/src/features/auth/presentation/pages/splash_screen.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/code_provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/visit_history_provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/repositories/visitor_code_repository.dart';
import 'package:vms_resident_app/src/core/navigation/route_observer.dart';
import 'package:pwa_install/pwa_install.dart';

// ThemeProvider class to manage the theme state
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup PWA install prompt for web
  PWAInstall().setup(); // <-- Initialize PWA prompt

  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient);
  final codeRepository = VisitorCodeRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    const Color primarySeedColor = Color(0xFF0057FF);
    const Color secondarySeedColor = Color(0xFF6C757D);

    // Define a common TextTheme using GoogleFonts
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.roboto(fontSize: 14),
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        secondary: secondarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    );

    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        secondary: secondarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF212529),
        foregroundColor: Colors.white,
        elevation: 0.5,
        titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF343A40),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'VMS Resident App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            LoginPage.routeName: (_) => const LoginPage(),
            ShellScreen.routeName: (_) => const ShellScreen(),
            ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
          },
        );
      },
    );
  }
}