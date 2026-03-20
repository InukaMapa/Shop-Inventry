import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🎭 Modern Abstract Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ).animate().scale(duration: 2.seconds, curve: Curves.easeOut),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ).animate().scale(duration: 2.seconds, delay: 500.ms, curve: Curves.easeOut),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(flex: 2),
                          
                          // 🚀 Logo / Icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/images/tech_zone_logo.png', 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)]),
                                  ),
                                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 48),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.5, 0.5)),
                
                          const SizedBox(height: 40),
                
                          // ✍️ Typography
                          Row(
                            children: [
                              Text(
                                'Tech\nZone.',
                                style: GoogleFonts.outfit(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -2,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Icon(Icons.shopping_bag_rounded, size: 40, color: theme.colorScheme.primary.withOpacity(0.5)),
                              ),
                            ],
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                
                          const SizedBox(height: 16),
                
                          Text(
                            'The next generation of asset management for modern tech enterprises.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueGrey.shade400,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                
                          const Spacer(flex: 3),
                
                          // 🔘 Buttons
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 12,
                                shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                  SizedBox(width: 12),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                
                          const SizedBox(height: 20),
                
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/register'),
                              child: Text(
                                'Create New Account',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 1000.ms),
                
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
