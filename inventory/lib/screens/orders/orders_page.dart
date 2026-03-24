import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/database_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await _dbService.getOrders();

      setState(() {
        _orders = response;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final total = (order['total_amount'] as num).toDouble();
                    final date = DateTime.parse(order['created_at']);
                    final status = order['status'] ?? 'Processing';
                    final orderId =
                        'ORD-${order['id'].toString().substring(0, 8)}';
                    final items =
                        List<Map<String, dynamic>>.from(order['items'] ?? []);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text(orderId,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateFormat.format(date),
                            style: const TextStyle(fontSize: 12)),
                        trailing: _buildStatusBadge(status),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Items Information',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ...items.map((item) {
                                  final qty = item['quantity'] ?? 1;
                                  final priceStr =
                                      item['processor']?.toString() ?? '0';
                                  final price = double.tryParse(
                                          priceStr.replaceAll(',', '')) ??
                                      0;
                                  final subTotal = price * qty;
                                  final imgUrl = item['image_url'];

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: imgUrl != null &&
                                                  imgUrl.isNotEmpty
                                              ? Image.network(imgUrl,
                                                  fit: BoxFit.cover)
                                              : Icon(Icons.dns_rounded,
                                                  size: 18,
                                                  color: theme
                                                      .colorScheme.primary
                                                      .withOpacity(0.3)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item['brand'] ?? 'Asset',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13)),
                                              Text(
                                                  'Rs. ${price.toStringAsFixed(0)} x $qty',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                            'Rs. ${subTotal.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Transaction:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Rs. ${total.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: theme.colorScheme.primary,
                                            fontSize: 18)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('User ID: ${order['user_id']}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Delivered' || status == 'Completed') color = Colors.green;
    if (status == 'Cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Orders History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('No orders found in database',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
