import 'package:flutter/material.dart';

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

  void addOrder(List<Map<String, dynamic>> items, double total) {
    _orders.insert(0, Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(items),
      total: total,
      date: DateTime.now(),
    ));
    notifyListeners();
  }
}
