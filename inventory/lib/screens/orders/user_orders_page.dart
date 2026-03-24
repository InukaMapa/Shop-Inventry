import 'package:flutter/material.dart';
import '../../providers/order_provider.dart';
import 'package:intl/intl.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  final orderProvider = OrderProvider();

  @override
  void initState() {
    super.initState();
    orderProvider.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1)),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: orderProvider,
        builder: (context, _) {
          final orders = orderProvider.orders;
          if (orders.isEmpty) return _buildEmptyState(theme);
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(theme, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 100, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          const Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Complete your shopping and track your orders here', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, Order order) {
    final dateFormat = DateFormat('MMM d, yyyy • hh:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text(order.status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Text(dateFormat.format(order.date), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                ...order.items.map((item) {
                  final qty = item['quantity'] ?? 1;
                  final priceStr = item['processor']?.toString() ?? '0';
                  final price = double.tryParse(priceStr.replaceAll(',', '')) ?? 0;
                  final subTotal = price * qty;
                  final imgUrl = item['image_url'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        // 📦 Small Thumbnail
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imgUrl != null && imgUrl.isNotEmpty
                              ? Image.network(imgUrl, fit: BoxFit.cover)
                              : Icon(Icons.dns_rounded, size: 20, color: theme.colorScheme.primary.withAlpha(100)),
                        ),
                        const SizedBox(width: 12),
                        
                        // 🏷 Name & Subtotal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['brand'] ?? 'Asset',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.2),
                              ),
                              Text(
                                'Rs. ${price.toStringAsFixed(0)} each',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        
                        // 🔢 Qty & Tot
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'x$qty',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            Text(
                              'Rs. ${subTotal.toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rs. ${order.total.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
