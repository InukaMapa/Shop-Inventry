import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchComputers();
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
          _filteredComputers = _allComputers.where((item) {
            final itemCategory = (item['storage'] ?? '').toString().toLowerCase();
            return itemCategory == widget.category!.toLowerCase();
          }).toList();
        } else {
          _filteredComputers = _allComputers;
        }
        
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load computers'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _deleteComputer(String id) async {
    try {
      await supabase.from('computers').delete().eq('id', id);
      _fetchComputers();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.category ?? 'Inventory',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 4,
              onPressed: () {
                Navigator.pushNamed(context, '/add-computer')
                    .then((_) => _fetchComputers());
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Asset', style: TextStyle(fontWeight: FontWeight.bold)),
            ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack)
          : null,

      body: _isLoading
          ? Center(child: const CircularProgressIndicator().animate().fadeIn())
          : _filteredComputers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 80, color: theme.colorScheme.outline.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        widget.category != null 
                          ? 'No ${widget.category} available'
                          : 'No assets available',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                )
              : RefreshIndicator(
                  onRefresh: _fetchComputers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredComputers.length,
                    itemBuilder: (context, index) {
                      final computer = _filteredComputers[index];
                      final imageUrl = computer['image_url'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ComputerDetailsPage(computer: computer),
                              ),
                            );
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 🖼 Image Thumbnail
                                Hero(
                                  tag: 'computer_img_${computer['id']}',
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _imagePlaceholder(theme),
                                          )
                                        : _imagePlaceholder(theme),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                // 📋 Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        computer['brand'] ?? 'Untitled Asset',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stock: ${computer['ram'] ?? '1'} Units',
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rs. ${computer['processor'] ?? '0'}',
                                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 18),
                                      ),
                                      _statusChip(computer['status']),
                                    ],
                                  ),
                                ),

                                // 🛠 Actions (Admin)
                                if (_isAdmin)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_note_rounded, color: Colors.indigoAccent),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddComputerPage(computer: computer),
                                            ),
                                          ).then((value) {
                                            if (value == true) _fetchComputers();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: const Text('Delete Asset'),
                                              content: const Text('Are you sure you want to permanently delete this asset?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.redAccent,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteComputer(computer['id']);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
                      );
                    },
                  ),
                ),
    );
  }

  // 🖼 Placeholder
  Widget _imagePlaceholder(ThemeData theme) {
    return Icon(Icons.computer_rounded, color: theme.colorScheme.primary.withOpacity(0.5), size: 36);
  }

  // 🏷 Status Chip
  Widget _statusChip(String? status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'Available':
        color = const Color(0xFF10B981); // Emerald
        icon = Icons.check_circle_rounded;
        break;
      case 'Out of Stock':
        color = const Color(0xFF6366F1); // Indigo
        icon = Icons.block_flipped;
        break;
      case 'In Use':
        color = const Color(0xFFF59E0B); // Amber
        icon = Icons.person_rounded;
        break;
      case 'Maintenance':
        color = const Color(0xFFEF4444); // Red
        icon = Icons.build_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status ?? 'Unknown',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

