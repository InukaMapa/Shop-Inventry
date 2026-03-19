import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    final fileName = 'asset_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await supabase.storage.from('computer-images').upload(fileName, _imageFile!, fileOptions: const FileOptions(upsert: true));
      return supabase.storage.from('computer-images').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  Future<void> _addAsset() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _assetTagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Required fields: Title, Price, Asset Tag'), behavior: SnackBarBehavior.floating));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inventory updated!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.computer != null ? 'Edit Equipment' : 'New Equipment', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 High-End Image Container
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.grey.shade100, width: 2),
                ),
                child: _imageFile != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(32), child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : _existingImageUrl != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(32), child: Image.network(_existingImageUrl!, fit: BoxFit.cover))
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.add_a_photo_rounded, size: 32, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: 12),
                                Text('Upload Product Image', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 48),
            _sectionTitle('Core Information'),
            const SizedBox(height: 20),
            _field(_titleController, 'Product Title', Icons.title_rounded),
            _field(_descriptionController, 'Short Description', Icons.description_rounded, maxLines: 2),
            _field(_assetTagController, 'Reference Tag / ID', Icons.qr_code_scanner_rounded),

            const SizedBox(height: 32),
            _sectionTitle('Inventory & Pricing'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _field(_priceController, 'Price (Rs.)', Icons.payments_rounded, keyboardType: TextInputType.number)),
                const SizedBox(width: 20),
                Expanded(child: _field(_quantityController, 'In Stock', Icons.inventory_2_rounded, keyboardType: TextInputType.number)),
              ],
            ),

            const SizedBox(height: 32),
            _sectionTitle('Status & Classification'),
            const SizedBox(height: 20),
            _dropdown('Product Status', Icons.info_outline_rounded, _status, ['Available', 'In Use', 'Maintenance', 'Out of Stock'], (v) => setState(() => _status = v!)),
            const SizedBox(height: 20),
            _dropdown('Inventory Category', Icons.category_rounded, _category, ['Desktops', 'Laptops', 'Accessories'], (v) => setState(() => _category = v!)),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 12,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.computer != null ? 'Apply Changes' : 'Register Equipment', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ).animate().scale(delay: 400.ms),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black));
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              contentPadding: const EdgeInsets.all(20),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, IconData icon, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w700)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

