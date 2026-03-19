import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pages
import 'screens/welcome/welcome_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/computers/computer_list_page.dart';
import 'screens/computers/add_computer_page.dart';
import 'screens/orders/orders_page.dart';
import 'screens/categories/categories_page.dart';
import 'screens/products/products_page.dart';
import 'screens/reports/reports_page.dart';

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
      title: 'Shop Inventory',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF14B8A6), // Teal
          surface: const Color(0xFFF8FAFC),
          background: const Color(0xFFF1F5F9),
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
              displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              displayMedium: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              bodyLarge: const TextStyle(color: Color(0xFF334155)),
              bodyMedium: const TextStyle(color: Color(0xFF475569)),
            ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1E293B),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
          primary: const Color(0xFF818CF8),
          secondary: const Color(0xFF2DD4BF),
          surface: const Color(0xFF1E293B),
          background: const Color(0xFF0F172A),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name ?? '/') {
          case '/':
            return MaterialPageRoute(builder: (_) => const WelcomePage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/dashboard':
            final role = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => DashboardPage(role: role));
          case '/computers':
            return MaterialPageRoute(builder: (_) => const ComputerListPage());
          case '/add-computer':
            return MaterialPageRoute(builder: (_) => const AddComputerPage());
          case '/orders':
            return MaterialPageRoute(builder: (_) => const OrdersPage());
          case '/categories':
            return MaterialPageRoute(builder: (_) => const CategoriesPage());
          case '/products':
            return MaterialPageRoute(builder: (_) => const ProductsPage());
          case '/reports':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => ReportsPage(
                totalRevenue: args['revenue'] ?? 0.0,
                totalOrders: args['orders'] ?? 0,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Route not found')),
              ),
            );
        }
      },
    );
  }
}
