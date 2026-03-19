import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_rounded, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 16),
            const Text('Categories Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Coming soon in the next update', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
