import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String? role;

  const DashboardPage({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Text(
          'Logged in as: ${role ?? 'user'}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
