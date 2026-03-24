import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _updateOrderStatus(dynamic orderId, String status) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
      
      _fetchOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Tracking', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -1)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
                final orderId = 'ORD-${order['id'].toString().substring(0,8)}';
                final items = List<Map<String, dynamic>>.from(order['items'] ?? []);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(dateFormat.format(date), style: const TextStyle(fontSize: 12)),
                    trailing: _buildStatusBadge(status),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Items Information', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              final qty = item['quantity'] ?? 1;
                              final priceStr = item['processor']?.toString() ?? '0';
                              final price = double.tryParse(priceStr.replaceAll(',', '')) ?? 0;
                              final subTotal = price * qty;
                              final imgUrl = item['image_url'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: imgUrl != null && imgUrl.isNotEmpty
                                          ? Image.network(imgUrl, fit: BoxFit.cover)
                                          : Icon(Icons.dns_rounded, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['brand'] ?? 'Asset', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text('Rs. ${price.toStringAsFixed(0)} x $qty', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    Text('Rs. ${subTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Transaction:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Rs. ${total.toStringAsFixed(0)}', 
                                  style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 18)),
                              ],
                            ),
                             const SizedBox(height: 24),
                             const SizedBox(height: 24),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                   children: [
                                     Icon(Icons.admin_panel_settings_rounded, size: 18, color: theme.colorScheme.primary),
                                     const SizedBox(width: 8),
                                     const Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13)),
                                   ],
                                 ),
                                 const SizedBox(height: 12),
                                 Wrap(
                                   spacing: 10,
                                   runSpacing: 10,
                                   children: ['Processing', 'Completed', 'Cancelled'].map((s) {
                                     final isSelected = status == s;
                                     return ChoiceChip(
                                       label: Text(s, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                                       selected: isSelected,
                                       selectedColor: theme.colorScheme.primary,
                                       backgroundColor: Colors.grey.shade50,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                       side: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade200),
                                       onSelected: (val) {
                                         if (val) _updateOrderStatus(order['id'], s);
                                       },
                                     );
                                   }).toList(),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 12),
                             Text('User DB Reference: ${order['user_id']}', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('Orders History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('No orders found in database', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
