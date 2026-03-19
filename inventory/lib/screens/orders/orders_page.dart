import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Orders Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('No active orders found', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
