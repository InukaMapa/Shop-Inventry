import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';

class ComputerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> computer;

  const ComputerDetailsPage({super.key, required this.computer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = computer['image_url'];
    final status = computer['status'] ?? 'Unknown';

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
                  background: Hero(
                    tag: 'computer_img_${computer['id']}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        image: imageUrl != null
                            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: imageUrl == null ? Icon(Icons.dns_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)) : null,
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
                              'Rs. ${computer['processor'] ?? '0'}',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          computer['brand'] ?? 'Premium Asset',
                          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hardware Model & ID: ${computer['model'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          'Key Specifications',
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 20),
                        
                        // 🛠 Grid of Specs
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.2,
                          children: [
                            _specTile(Icons.memory_rounded, 'RAM / Cap', '${computer['ram'] ?? '0'} Units'),
                            _specTile(Icons.storage_rounded, 'Type', computer['storage'] ?? 'N/A'),
                            _specTile(Icons.calendar_today_rounded, 'Added', 'Recently'),
                            _specTile(Icons.verified_user_rounded, 'Warranty', 'Standard'),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        Text(
                          'Product Overview',
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This high-performance unit provides professional-grade reliability for demanding workloads. Built with precision and efficiency in mind, it represents the pinnacle of modern enterprise computing equipment.',
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade600, height: 1.6),
                        ),
                        const SizedBox(height: 120), // Spacing for bottom button
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
                   CartProvider().addToCart(computer);
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: const Text('Added to tracklist!'), behavior: SnackBarBehavior.floating, backgroundColor: theme.colorScheme.primary),
                   );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart_rounded),
                    SizedBox(width: 12),
                    Text('Reserve Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _specTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w700)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
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

