import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddComputerPage extends StatefulWidget {
  const AddComputerPage({super.key});

  @override
  State<AddComputerPage> createState() => _AddComputerPageState();
}

class _AddComputerPageState extends State<AddComputerPage> {
  final _assetTagController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _processorController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();

  String _status = 'Available';
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _addComputer() async {
    if (_assetTagController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _modelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.from('computers').insert({
        'asset_tag': _assetTagController.text.trim(),
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'processor': _processorController.text.trim(),
        'ram': _ramController.text.trim(),
        'storage': _storageController.text.trim(),
        'status': _status,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Computer added successfully')),
      );

      Navigator.pop(context); // go back to list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Add Computer'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(
              controller: _assetTagController,
              label: 'Asset Tag *',
              icon: Icons.tag,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _brandController,
              label: 'Brand *',
              icon: Icons.business,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _modelController,
              label: 'Model *',
              icon: Icons.computer,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _processorController,
              label: 'Processor',
              icon: Icons.memory,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ramController,
              label: 'RAM',
              icon: Icons.storage,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _storageController,
              label: 'Storage',
              icon: Icons.sd_storage,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(value: 'In Use', child: Text('In Use')),
                DropdownMenuItem(
                    value: 'Maintenance', child: Text('Maintenance')),
              ],
              onChanged: (value) => setState(() => _status = value!),
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.info),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addComputer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Computer',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
