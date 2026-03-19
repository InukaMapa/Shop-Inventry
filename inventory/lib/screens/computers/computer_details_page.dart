import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';

class ComputerDetailsPage extends StatefulWidget {
  final Map<String, dynamic> computer;

  const ComputerDetailsPage({super.key, required this.computer});

  @override
  State<ComputerDetailsPage> createState() => _ComputerDetailsPageState();
}

class _ComputerDetailsPageState extends State<ComputerDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = widget.computer['image_url'];
    final status = widget.computer['status'] ?? 'Unknown';
    final maxQty = int.tryParse(widget.computer['ram']?.toString() ?? '1') ?? 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Hero(
                    tag: 'computer_img_${widget.computer['id']}',
                    child: Container(
                      color: Colors.grey.shade50,
                      child: (imageUrl != null && imageUrl.toString().isNotEmpty)
                          ? Image.network(
                              imageUrl, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.dns_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
                            )
                          : Icon(Icons.dns_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusChip(status),
                            Text(
                              'Rs. ${widget.computer['processor'] ?? '0'}',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.computer['brand'] ?? 'Premium Asset',
                          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hardware Model & ID: ${widget.computer['model'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 48),
                        
                        // 📦 Quantity Selector Section
                        Text(
                          'Select Quantity',
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _qtyButton(Icons.remove_rounded, () {
                                    if (_quantity > 1) setState(() => _quantity--);
                                  }),
                                  const SizedBox(width: 24),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(width: 24),
                                  _qtyButton(Icons.add_rounded, () {
                                    if (_quantity < maxQty) setState(() => _quantity++);
                                  }),
                                ],
                              ),
                              const SizedBox.shrink(),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 180), // Spacing for bottom button
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.1, duration: 500.ms),
              ),
            ],
          ),
          
          // 🔘 Action Button at Bottom
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 12,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                ),
                onPressed: () {
                   CartProvider().addToCart(widget.computer, quantity: _quantity);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                        content: Text('Added $_quantity to tracklist!'), 
                        behavior: SnackBarBehavior.floating, 
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                   );
                   Navigator.pop(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart_rounded),
                    SizedBox(width: 12),
                    Text('Add to Tracklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'Available': color = const Color(0xFF10B981); break;
      case 'Maintenance': color = const Color(0xFFEF4444); break;
      default: color = const Color(0xFF6366F1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
      ),
    );
  }
}

