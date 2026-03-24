import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pages
import 'screens/welcome/welcome_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/computers/add_computer_page.dart';
import 'screens/orders/orders_page.dart';
import 'screens/categories/categories_page.dart';
import 'screens/computers/computer_list_page.dart';
import 'screens/dashboard/main_navigation_page.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lqopsjohrolonvkkcikh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxxb3Bzam9ocm9sb252a2tjaWtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwNTQ3OTcsImV4cCI6MjA4MzYzMDc5N30.IMhbOv5z9j7SBRqWUTJcg_yrmiThQpMUn29aSzz81Es',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          primary: const Color(0xFF6366F1),
          surface: Colors.white,
          surfaceContainer: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
        ),
      ),
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        if (settings.name == '/login') return MaterialPageRoute(builder: (_) => const LoginPage());
        if (settings.name == '/register') return MaterialPageRoute(builder: (_) => const RegisterPage());
        if (settings.name == '/orders') return MaterialPageRoute(builder: (_) => const OrdersPage());
        if (settings.name == '/add-computer') return MaterialPageRoute(builder: (_) => const AddComputerPage());
        if (settings.name == '/computers') return MaterialPageRoute(builder: (_) => const ComputerListPage());
        if (settings.name == '/categories') return MaterialPageRoute(builder: (_) => const CategoriesPage());
        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // If snapshot is disconnected or session is null, go to welcome
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
        
        if (session == null) {
          return const WelcomePage();
        }

        // Use a Key to force rebuild when user changes
        return FutureBuilder<Map<String, dynamic>?>(
          key: ValueKey(session.user.id),
          future: Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', session.user.id)
              .maybeSingle()
              .timeout(const Duration(seconds: 15), onTimeout: () => null),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Determine role with more priority to profile data
            String role = 'user';
            if (profileSnapshot.hasData && profileSnapshot.data != null) {
              role = profileSnapshot.data!['role']?.toString().toLowerCase() == 'admin' ? 'admin' : 'user';
            } else if (session.user.userMetadata?['role']?.toString().toLowerCase() == 'admin') {
              role = 'admin';
            }
            
            return MainNavigationPage(role: role);
          },
        );
      },
    );
  }
}

