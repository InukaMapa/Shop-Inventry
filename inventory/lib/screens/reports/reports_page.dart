import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;

  const ReportsPage({super.key, this.totalRevenue = 0, this.totalOrders = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue Reports'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildReportCard(theme, 'Gross Revenue', 'Rs. ${totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet_rounded, Colors.green),
            const SizedBox(height: 16),
            _buildReportCard(theme, 'Average Order Value', 'Rs. ${(totalOrders > 0 ? totalRevenue / totalOrders : 0).toStringAsFixed(2)}', Icons.analytics_rounded, Colors.blue),
            const SizedBox(height: 32),
            const Text('Periodic Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildListItem('Monthly Growth', '+12.5%'),
            _buildListItem('Quarterly Target', '85% Achieved'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String trailing) {
    return ListTile(
      title: Text(title),
      trailing: Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
