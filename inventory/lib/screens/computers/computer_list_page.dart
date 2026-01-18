import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'computer_details_page.dart';

class ComputerListPage extends StatefulWidget {
  const ComputerListPage({super.key});

  @override
  State<ComputerListPage> createState() => _ComputerListPageState();
}

class _ComputerListPageState extends State<ComputerListPage> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _computers = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchComputers();
  }

  // 🔹 Load user role
  Future<void> _loadUserRole() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile['role'] == 'admin') {
        if (mounted) setState(() => _isAdmin = true);
      }
    } catch (_) {}
  }

  // 🔹 Fetch computers
  Future<void> _fetchComputers() async {
    try {
      final data = await supabase
          .from('computers')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _computers = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load computers')),
      );
    }
  }

  // 🔹 Delete computer (Admin only)
  Future<void> _deleteComputer(String id) async {
    try {
      await supabase.from('computers').delete().eq('id', id);
      _fetchComputers();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Computer Inventory'),
        backgroundColor: Colors.blue,
      ),

      // ➕ Add (Admin only)
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.pushNamed(context, '/add-computer')
                    .then((_) => _fetchComputers());
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _computers.isEmpty
              ? const Center(
                  child: Text(
                    'No computers available',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _computers.length,
                  itemBuilder: (context, index) {
                    final computer = _computers[index];
                    final imageUrl = computer['image_url'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ComputerDetailsPage(computer: computer),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 🖼 Image Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                            ),

                            const SizedBox(width: 16),

                            // 📋 Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    computer['brand'] ?? 'Unknown Brand',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    computer['asset_tag'] ?? 'No Asset Tag',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  _statusChip(computer['status']),
                                ],
                              ),
                            ),

                            // ❌ Delete (Admin)
                            if (_isAdmin)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete Computer'),
                                      content: const Text(
                                          'Are you sure you want to delete this computer?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteComputer(computer['id']);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // 🖼 Placeholder
  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.computer, color: Colors.grey),
    );
  }

  // 🏷 Status Chip
  Widget _statusChip(String? status) {
    Color color;
    switch (status) {
      case 'Available':
        color = Colors.green;
        break;
      case 'In Use':
        color = Colors.orange;
        break;
      case 'Maintenance':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
