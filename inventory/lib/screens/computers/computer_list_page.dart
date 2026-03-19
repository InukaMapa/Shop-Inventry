import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'computer_details_page.dart';
import 'add_computer_page.dart';

class ComputerListPage extends StatefulWidget {
  final String? category;
  const ComputerListPage({super.key, this.category});

  @override
  State<ComputerListPage> createState() => _ComputerListPageState();
}

class _ComputerListPageState extends State<ComputerListPage> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _allComputers = [];
  List<Map<String, dynamic>> _filteredComputers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchComputers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredComputers = _allComputers.where((item) {
        final query = _searchController.text.toLowerCase();
        final brand = (item['brand'] ?? '').toString().toLowerCase();
        final model = (item['model'] ?? '').toString().toLowerCase();
        return brand.contains(query) || model.contains(query);
      }).toList();
    });
  }

  Future<void> _loadUserRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile['role'].toString().trim().toLowerCase() == 'admin') {
        if (mounted) setState(() => _isAdmin = true);
      }
    } catch (_) {}
  }

  Future<void> _fetchComputers() async {
    try {
      final data = await supabase
          .from('computers')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _allComputers = List<Map<String, dynamic>>.from(data);
        
        if (widget.category != null) {
          _allComputers = _allComputers.where((item) {
            final itemCategory = (item['storage'] ?? '').toString().toLowerCase();
            return itemCategory == widget.category!.toLowerCase();
          }).toList();
        }
        
        _filteredComputers = _allComputers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load inventory'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _deleteComputer(String id) async {
    try {
      await supabase.from('computers').delete().eq('id', id);
      _fetchComputers();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deletion failed'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                widget.category ?? 'Inventory Explorer',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 24,
                  letterSpacing: -1,
                ),
              ),
              background: Container(color: Colors.white),
            ),
            actions: [
              if (_isAdmin)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-computer').then((_) => _fetchComputers());
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),

          // 🔍 Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search brand or model...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredComputers.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    Text(
                      'No assets found matching your criteria',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final computer = _filteredComputers[index];
                    return _AssetCard(
                      computer: computer,
                      isAdmin: _isAdmin,
                      onDelete: () => _deleteComputer(computer['id']),
                      onEdit: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddComputerPage(computer: computer)),
                        ).then((value) {
                          if (value == true) _fetchComputers();
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ComputerDetailsPage(computer: computer)),
                        );
                      },
                    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.1, end: 0);
                  },
                  childCount: _filteredComputers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Map<String, dynamic> computer;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AssetCard({
    required this.computer,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = computer['image_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 📦 Modern Thumbnail
              Hero(
                tag: 'computer_img_${computer['id']}',
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.grey.shade50,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.toString().isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Icon(Icons.dns_rounded, color: theme.colorScheme.primary.withOpacity(0.3), size: 32),
                ),
              ),
              const SizedBox(width: 16),

              // 📝 Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      computer['brand'] ?? 'Unknown Brand',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Quantity: ${computer['ram'] ?? '0'} Units',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'Rs. ${computer['processor'] ?? '0'}',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                  ],
                ),
              ),

              // 🏷 Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusChip(computer['status']),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent), onPressed: onEdit, iconSize: 22, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent), onPressed: _showDeleteDialog(context), iconSize: 22, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback _showDeleteDialog(BuildContext context) {
    return () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Remove Asset'),
          content: const Text('Permanently remove this item from inventory?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep it')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    };
  }

  Widget _statusChip(String? status) {
    Color color;
    switch (status) {
      case 'Available': color = const Color(0xFF10B981); break;
      case 'Out of Stock': color = const Color(0xFF6366F1); break;
      case 'Maintenance': color = const Color(0xFFEF4444); break;
      default: color = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(
        status ?? 'N/A',
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );
  }
}

