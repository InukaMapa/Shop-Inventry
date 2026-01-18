import 'package:flutter/material.dart';

class ComputerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> computer;

  const ComputerDetailsPage({
    super.key,
    required this.computer,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = computer['image_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Computer Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Computer Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imagePlaceholder(height: 220),
                    )
                  : _imagePlaceholder(height: 220),
            ),

            const SizedBox(height: 24),

            // 🏷 Brand & Asset Tag
            Text(
              computer['brand'] ?? 'Unknown Brand',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Asset Tag: ${computer['asset_tag'] ?? '-'}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // 📋 Details Card
            _detailCard(),
          ],
        ),
      ),
    );
  }

  Widget _detailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow('Model', computer['model']),
          _detailRow('Processor', computer['processor']),
          _detailRow('RAM', computer['ram']),
          _detailRow('Storage', computer['storage']),
          _detailRow('Status', computer['status']),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : '-',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder({double height = 150}) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.computer, size: 60, color: Colors.grey),
      ),
    );
  }
}
