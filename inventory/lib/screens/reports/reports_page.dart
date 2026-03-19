import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReportsPage extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;

  const ReportsPage({super.key, this.totalRevenue = 542000, this.totalOrders = 42}); // Default mocks for UI demo

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Financial Intelligence', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -1)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Primary Revenue Card
            _buildHighlightCard(
              theme, 
              'Cumulative Revenue', 
              'Rs. ${totalRevenue.toStringAsFixed(0)}', 
              Icons.payments_rounded, 
              theme.colorScheme.primary,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // 📈 Analytics Row
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Order Velocity', 
                    '${totalOrders} Completed', 
                    Icons.speed_rounded, 
                    Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStat(
                    'Avg. Value', 
                    'Rs. ${(totalOrders > 0 ? totalRevenue / totalOrders : 0).toStringAsFixed(0)}', 
                    Icons.trending_up_rounded, 
                    Colors.teal,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 48),

            Text('Quarterly Diagnostics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
            const SizedBox(height: 20),

            _buildAnalysisRow('Gross Margin Efficiency', '92.4%', Colors.teal),
            _buildAnalysisRow('Inventory Turnover', '3.8x', Colors.blue),
            _buildAnalysisRow('Customer Retention', '84.1%', Colors.indigo),
            _buildAnalysisRow('System Uptime', '100%', Colors.orange),

            const SizedBox(height: 60),
            
            // 📝 Insight Note
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.amber),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Revenue is up 12% compared to the previous quarter. Performance remains optimal.',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
             child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w800, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String title, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: statusColor)),
        ],
      ),
    );
  }
}
