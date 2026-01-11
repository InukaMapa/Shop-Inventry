import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // 🔹 Get user role
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
        setState(() => _isAdmin = true);
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

      setState(() {
        _computers = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading computers')),
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
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Computer Inventory'),
        backgroundColor: Colors.blue,
      ),

      // ➕ Add button (Admin only)
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
                    'No computers found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _computers.length,
                  itemBuilder: (context, index) {
                    final computer = _computers[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const Icon(Icons.computer, color: Colors.blue),
                        title: Text(
                          computer['asset_tag'] ?? 'No Asset Tag',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${computer['brand']} • ${computer['status']}',
                        ),

                        // ❌ Delete (Admin only)
                        trailing: _isAdmin
                            ? IconButton(
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
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
