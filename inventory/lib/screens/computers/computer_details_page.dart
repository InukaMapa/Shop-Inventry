import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/cart_provider.dart';

class ComputerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> computer;

  const ComputerDetailsPage({
    super.key,
    required this.computer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = computer['image_url'];
    final status = computer['status'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'computer_img_${computer['id']}',
                child: Container(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(theme),
                        )
                      : _imagePlaceholder(theme),
                ),
              ),
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  computer['brand'] ?? 'Unknown Brand',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asset Tag',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              computer['asset_tag'] ?? '-',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(status),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  Text(
                    'Device Specifications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

                  const SizedBox(height: 16),

                  // 📋 Details Card
                  _detailCard(theme).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 48),

                  if (status == 'Available')
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                        ),
                        onPressed: () {
                          CartProvider().addToCart(computer);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Added to cart successfully!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: theme.colorScheme.primary,
                              action: SnackBarAction(
                                label: 'View Cart',
                                textColor: Colors.white,
                                onPressed: () => Navigator.pop(context), // Go back and user can navigate to cart
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_checkout_rounded),
                            SizedBox(width: 12),
                            Text('Add to Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _detailRow(theme, 'Price', 'Rs. ${computer['processor']}', Icons.payments_rounded),
          const Divider(height: 30),
          _detailRow(theme, 'Stock Quantity', '${computer['ram']} Units', Icons.inventory_2_rounded),
          const Divider(height: 30),
          _detailRow(theme, 'Description', computer['model'] ?? 'No description provided', Icons.description_rounded),
          const Divider(height: 30),
          _detailRow(theme, 'Asset Tag', computer['asset_tag'] ?? '-', Icons.qr_code_rounded),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, dynamic value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value != null && value.toString().isNotEmpty ? value.toString() : 'Not Specified',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
      child: Center(
        child: Icon(Icons.computer_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'Available':
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'In Use':
        color = const Color(0xFFF59E0B);
        icon = Icons.person_rounded;
        break;
      case 'Maintenance':
        color = const Color(0xFFEF4444);
        icon = Icons.build_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

