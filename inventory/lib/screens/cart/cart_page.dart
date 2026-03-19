import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cart = CartProvider();
  final orders = OrderProvider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = cart.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Basket', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -1)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
              ),
              onPressed: () => setState(() => cart.clearCart()),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState(theme)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItem(theme, item, index);
                    },
                  ),
                ),
                _buildCheckoutSection(theme),
              ],
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Container(
             padding: const EdgeInsets.all(32),
             decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), shape: BoxShape.circle),
             child: Icon(Icons.shopping_basket_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
           ),
          const SizedBox(height: 32),
          Text('Basket is empty', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Start adding high-end tech to your collection.', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          const SizedBox(height: 48),
          SizedBox(
            width: 200,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Go Shopping', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildCartItem(ThemeData theme, CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          // 📦 Item Image
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
            child: item.computer['image_url'] != null
                ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(item.computer['image_url'], fit: BoxFit.cover))
                : Icon(Icons.dns_rounded, color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          const SizedBox(width: 16),
          // 📝 Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.computer['brand'] ?? 'Asset', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Rs. ${item.computer['processor']}', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 15)),
              ],
            ),
          ),
          // 🔢 Quantity Controls
          Container(
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                IconButton(icon: const Icon(Icons.add_rounded, size: 18), onPressed: () => setState(() => cart.addToCart(item.computer))),
                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                IconButton(icon: const Icon(Icons.remove_rounded, size: 18), onPressed: () => setState(() => cart.removeFromCart(item.computer['id']))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
  }

  Widget _buildCheckoutSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Investment Total', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
                Text('Rs. ${cart.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 12,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                ),
                onPressed: () => _showPlaceOrderForm(),
                child: const Text('Complete Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.5, duration: 600.ms);
  }

  void _showPlaceOrderForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlaceOrderForm(onSuccess: () {
        setState(() {
          final items = cart.items.map((e) => e.computer).toList();
          orders.addOrder(items, cart.totalAmount);
          cart.clearCart();
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Order placed successfully!'), behavior: SnackBarBehavior.floating, backgroundColor: Theme.of(context).colorScheme.primary));
      }),
    );
  }
}

class _PlaceOrderForm extends StatelessWidget {
  final VoidCallback onSuccess;
  const _PlaceOrderForm({required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 32),
            Text('Finalize Order', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 32),
            _inputField('Full Name', Icons.person_outline_rounded),
            _inputField('Contact Number', Icons.phone_iphone_rounded),
            _inputField('Shipping Address', Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                onPressed: onSuccess,
                child: const Text('Confirm Purchase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
