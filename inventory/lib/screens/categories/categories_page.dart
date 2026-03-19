import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/database_service.dart';
import '../computers/computer_list_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _dbService.getCategories();
      if (!mounted) return;
      
      setState(() {
        _categories = cats.isNotEmpty ? cats : [
          {'title': 'Desktops', 'icon_name': 'desktop_windows_rounded', 'color_hex': 'FF448AFF'},
          {'title': 'Laptops', 'icon_name': 'laptop_rounded', 'color_hex': 'FF536DFE'},
          {'title': 'Accessories', 'icon_name': 'keyboard_rounded', 'color_hex': 'FFFFC107'},
        ];
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Inventory Segments', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: -1)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddCategoryDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: theme.colorScheme.primary, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Categories', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('${_categories.length} total', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return _CategoryTile(
                      title: cat['title'],
                      icon: _getIconData(cat['icon_name']),
                      color: _getColor(cat['color_hex']),
                      onTap: () => _navigateToCategory(context, cat['title']),
                    );
                  },
                ),
              ),
          ],
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),
      ),
    );
  }

  IconData _getIconData(String? name) {
    if (name == 'desktop_windows_rounded') return Icons.desktop_windows_rounded;
    if (name == 'laptop_rounded') return Icons.laptop_rounded;
    if (name == 'keyboard_rounded') return Icons.keyboard_rounded;
    return Icons.category_rounded;
  }

  Color _getColor(String? hex) {
    if (hex == null) return Colors.blueGrey;
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComputerListPage(category: category)),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('New Category', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g. Workstations',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await _dbService.addCategory(controller.text, iconName: 'category_rounded', colorHex: 'FF607D8B');
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchCategories();
                  }
                } catch (e) {
                   if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add category: $e')));
                  }
                }
              }
            }, 
            child: const Text('Add Segment'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
