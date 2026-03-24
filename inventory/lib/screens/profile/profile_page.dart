import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Account', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -1)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            // 👤 Profile Avatar Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                      child: Icon(Icons.person_rounded, size: 54, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email?.split('@')[0].toUpperCase() ?? 'TECH USER',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Not signed in',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 48),

            // 📋 Info Cards
            _profileTile(Icons.alternate_email_rounded, 'Email Address', user?.email ?? 'N/A'),
            _profileTile(Icons.verified_user_rounded, 'Account Type', 'Pro Access'),
            _profileTile(Icons.security_rounded, 'Security', 'Standard Auth'),

            const SizedBox(height: 60),

            // 🚪 Logout Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.05),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.1)),
                ),
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text('Terminate Session', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 12),
            Text('Version 2.4.0 • Enterprise Edition', style: TextStyle(color: Colors.grey.shade300, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w800, fontSize: 10)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
