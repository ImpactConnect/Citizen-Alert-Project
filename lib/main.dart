import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'constants/theme_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/supabase_test.dart';
import 'providers/report_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Test Supabase connection
  try {
    await SupabaseTest().testConnection();
  } catch (e) {
    print('Supabase test failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        // Add other providers here as needed
      ],
      child: MaterialApp(
        title: 'Citizen Alert',
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AppStartup(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        // Handle profile and settings navigation in HomeAppBar
        onGenerateRoute: (settings) {
          if (settings.name == '/profile') {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Profile')),
                body: const Center(child: Text('Profile Screen - Coming Soon')),
              ),
            );
          }
          if (settings.name == '/settings') {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Settings')),
                body:
                    const Center(child: Text('Settings Screen - Coming Soon')),
              ),
            );
          }
          if (settings.name == '/notifications') {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Notifications')),
                body: const Center(
                  child: Text('Notifications Screen - Coming Soon'),
                ),
              ),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text('Route ${settings.name} not found'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add any additional initialization logic here
    // For example, loading initial data, checking permissions, etc.

    await Future.delayed(const Duration(seconds: 2)); // Simulated delay

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SplashScreen();
    }

    return const AuthWrapper();
  }
}
