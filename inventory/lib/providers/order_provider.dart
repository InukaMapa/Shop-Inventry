import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime date;
  final String status;

  Order({required this.id, required this.items, required this.total, required this.date, this.status = 'Processing'});
}

class OrderProvider extends ChangeNotifier {
  static final OrderProvider _instance = OrderProvider._internal();
  factory OrderProvider() => _instance;
  OrderProvider._internal();

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final data = List<Map<String, dynamic>>.from(response);
      _orders.clear();
      for (var o in data) {
        try {
          final itemsRaw = o['items'];
          final items = itemsRaw != null ? List<Map<String, dynamic>>.from(itemsRaw) : <Map<String, dynamic>>[];
          
          final totalVal = o['total_amount'];
          double totalAmount = 0;
          if (totalVal != null) {
            totalAmount = double.tryParse(totalVal.toString()) ?? 0.0;
          }
          
          _orders.add(Order(
            id: o['id'].toString().length > 8 ? 'ORD-${o['id'].toString().substring(0, 8)}' : 'ORD-${o['id']}',
            items: items,
            total: totalAmount,
            date: o['created_at'] != null ? DateTime.parse(o['created_at']) : DateTime.now(),
            status: o['status'] ?? 'Processing',
          ));
        } catch (e) {
          debugPrint('Single order parsing error: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch orders error: $e');
    }
  }

  Future<void> addOrder(List<Map<String, dynamic>> items, double total) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    // 1. Create the Order in local list for immediate UI feedback
    final newOrder = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(items),
      total: total,
      date: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    notifyListeners();

    try {
      // 2. Insert into Supabase 'orders' table
      await supabase.from('orders').insert({
        'user_id': userId,
        'total_amount': total,
        'status': 'Processing',
        'items': items,
      });

      // 3. Update stock/status in 'computers' table
      for (var item in items) {
        final currentQty = int.tryParse(item['ram']?.toString() ?? '0') ?? 0;
        final orderedQty = item['quantity'] is int ? item['quantity'] : (int.tryParse(item['quantity']?.toString() ?? '1') ?? 1);
        final newQty = (currentQty - orderedQty).clamp(0, 9999);
        
        await supabase.from('computers').update({
          'status': newQty == 0 ? 'Out of Stock' : 'Available',
          'ram': newQty.toString(),
        }).eq('id', item['id']);
      }
    } catch (e) {
      debugPrint('Order processing error: $e');
    }
  }
}
