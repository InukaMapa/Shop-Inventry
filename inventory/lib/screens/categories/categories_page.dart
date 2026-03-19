import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Taxonomy', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -1)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.category_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            const SizedBox(height: 32),
            Text('Segment Mapping', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'SYSTEM RESTRICTED',
                style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Advanced category governance is scheduled\nfor the Q3 Infrastructure Update.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
            ),
          ],
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),
      ),
    );
  }
}
