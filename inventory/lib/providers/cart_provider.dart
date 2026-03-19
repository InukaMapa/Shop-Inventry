import 'package:flutter/material.dart';

class CartItem {
  final Map<String, dynamic> computer;
  int quantity;

  CartItem({required this.computer, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      final priceStr = item.computer['processor']?.toString() ?? '0';
      final price = double.tryParse(priceStr.replaceAll(',', '')) ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  void addToCart(Map<String, dynamic> computer, {int quantity = 1}) {
    // Check if already in cart
    final index = _items.indexWhere((item) => item.computer['id'] == computer['id']);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(computer: computer, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.computer['id'] == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
