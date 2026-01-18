import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _imageFile;

  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  // 📸 Pick image from gallery
  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // ☁ Upload image to Supabase Storage
  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final fileName = 'computer_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('computer-images').upload(
          fileName,
          _imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('computer-images').getPublicUrl(fileName);
  }

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
      final imageUrl = await _uploadImage();

      await supabase.from('computers').insert({
        'asset_tag': _assetTagController.text.trim(),
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'processor': _processorController.text.trim(),
        'ram': _ramController.text.trim(),
        'storage': _storageController.text.trim(),
        'status': _status,
        'image_url': imageUrl, // nullable
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Computer added successfully')),
      );

      Navigator.pop(context);
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Add Computer'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 🖼 Image Picker Card
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Add Computer Image'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            _field(_assetTagController, 'Asset Tag *', Icons.tag),
            _field(_brandController, 'Brand *', Icons.business),
            _field(_modelController, 'Model *', Icons.computer),
            _field(_processorController, 'Processor', Icons.memory),
            _field(_ramController, 'RAM', Icons.storage),
            _field(_storageController, 'Storage', Icons.sd_storage),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _status,
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
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addComputer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Computer',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
