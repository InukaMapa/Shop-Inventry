import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddComputerPage extends StatefulWidget {
  final Map<String, dynamic>? computer;
  const AddComputerPage({super.key, this.computer});

  @override
  State<AddComputerPage> createState() => _AddComputerPageState();
}

class _AddComputerPageState extends State<AddComputerPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _assetTagController = TextEditingController();

  String _status = 'Available';
  String _category = 'Desktops';
  bool _isLoading = false;
  String? _existingImageUrl;

  File? _imageFile;

  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.computer != null) {
      _titleController.text = widget.computer!['brand'] ?? '';
      _descriptionController.text = widget.computer!['model'] ?? '';
      _priceController.text = widget.computer!['processor'] ?? '';
      _quantityController.text = widget.computer!['ram'] ?? '';
      _assetTagController.text = widget.computer!['asset_tag'] ?? '';
      _status = widget.computer!['status'] ?? 'Available';
      _category = widget.computer!['storage'] ?? 'Desktops';
      _existingImageUrl = widget.computer!['image_url'];
    }
  }

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

    final fileName = 'asset_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await supabase.storage.from('computer-images').upload(
            fileName,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );
      return supabase.storage.from('computer-images').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _addAsset() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _assetTagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields (Title, Price, Asset Tag)'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage() ?? _existingImageUrl;

      final data = {
        'brand': _titleController.text.trim(),
        'model': _descriptionController.text.trim(),
        'processor': _priceController.text.trim(),
        'ram': _quantityController.text.trim(),
        'asset_tag': _assetTagController.text.trim(),
        'status': _status,
        'image_url': imageUrl,
        'storage': _category,
      };

      if (widget.computer != null) {
        await supabase.from('computers').update(data).eq('id', widget.computer!['id']);
      } else {
        await supabase.from('computers').insert(data);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.computer != null ? 'Asset updated successfully' : 'Asset added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.computer != null ? 'Edit Asset' : 'Add New Asset', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // 🖼 Image Picker Card
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: (_imageFile == null && _existingImageUrl == null) ? theme.colorScheme.outline.withOpacity(0.3) : Colors.transparent,
                    width: 2,
                    style: (_imageFile == null && _existingImageUrl == null) ? BorderStyle.solid : BorderStyle.none,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      ).animate().fadeIn()
                    : _existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                          ).animate().fadeIn()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 54, color: theme.colorScheme.primary),
                              const SizedBox(height: 12),
                              const Text(
                                'Tap to Add Asset Image',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ],
                          ).animate().fade().scale(),
              ),
            ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms),

            const SizedBox(height: 32),

            Column(
              children: [
                _field(_titleController, 'Asset Title *', Icons.title_rounded, 0),
                _field(_descriptionController, 'Description', Icons.description_rounded, 100, maxLines: 3),
                Row(
                  children: [
                    Expanded(child: _field(_priceController, 'Price (Sri Lanka Rs.) *', Icons.payments_rounded, 200, keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _field(_quantityController, 'Quantity', Icons.inventory_2_rounded, 300, keyboardType: TextInputType.number)),
                  ],
                ),
                _field(_assetTagController, 'Asset Tag / Serial *', Icons.qr_code_rounded, 400),

                DropdownButtonFormField<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(value: 'Desktops', child: Text('Desktops')),
                    DropdownMenuItem(value: 'Laptops', child: Text('Laptops')),
                    DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
                  ],
                  onChanged: (value) => setState(() => _category = value!),
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'Available', child: Text('Available')),
                    DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                    DropdownMenuItem(value: 'In Use', child: Text('In Use')),
                    DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (value) => setState(() => _status = value!),
                  decoration: const InputDecoration(
                    labelText: 'Asset Status',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addAsset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.computer != null ? 'Update Asset' : 'Publish Asset', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, int delay, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          alignLabelWithHint: maxLines > 1,
        ),
      ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideX(begin: -0.05),
    );
  }
}

