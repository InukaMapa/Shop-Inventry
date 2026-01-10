import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Pages
import 'screens/welcome/welcome_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/dashboard/dashboard_page.dart';
/*import 'screens/computers/computer_list_page.dart';*/

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const WelcomePage(),
            );

          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );

          case '/register':
            return MaterialPageRoute(
              builder: (_) => const RegisterPage(),
            );

          case '/dashboard':
            final role = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => DashboardPage(role: role),
            );

          /*case '/computers':
            return MaterialPageRoute(
              builder: (_) => const ComputerListPage(),
            );*/

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
