import 'package:Tiffinity/views/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/services/image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddMenuItemPage extends StatefulWidget {
  final Map? existingItem; // optional for editing
  final String messId; // ✅ required
  final String? menuId; // ✅ optional for editing
  final String? existingImageUrl; // ✅ Task 8 - for editing

  const AddMenuItemPage({
    super.key,
    required this.messId,
    this.existingItem,
    this.menuId,
    this.existingImageUrl,
  });

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = "Veg";
  bool _isLoading = false;

  File? _foodImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill when editing
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!['name'] ?? '';
      _priceController.text = widget.existingItem!['price'].toString();
      _descriptionController.text = widget.existingItem!['description'] ?? '';
      _type = widget.existingItem!['type'] ?? "Veg";
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Food Photo'),
          content: const Text('Choose where to upload photo from:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickFoodImageFromGallery();
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickFoodImageFromCamera();
              },
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );
  }

  Future _pickFoodImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / 1024 / 1024;
        if (fileSize > 32 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Image too large: ${fileSizeMB.toStringAsFixed(2)}MB\nMax: 32MB allowed',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        setState(() => _foodImage = file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Image selected: ${fileSizeMB.toStringAsFixed(2)}MB',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future _pickFoodImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / 1024 / 1024;
        if (fileSize > 32 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ Image too large: ${fileSizeMB.toStringAsFixed(2)}MB\nMax: 32MB allowed',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        setState(() => _foodImage = file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Image selected: ${fileSizeMB.toStringAsFixed(2)}MB',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _saveItem() async {
    if (widget.menuId == null && _foodImage == null) {
      _showError("Please upload a food item image (Required Field)");
      return;
    }

    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? foodImageUrl = widget.existingImageUrl;

      if (_foodImage != null) {
        print('🖼️ Uploading menu item image...');
        foodImageUrl = await ImageService.uploadToImgBB(_foodImage!);

        if (foodImageUrl == 'SIZE_EXCEEDED') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Image too large! Maximum 32MB allowed.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }

        if (foodImageUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Image upload failed. Check internet.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      final menuItem = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text,
        'type': _type,
        'updatedAt': FieldValue.serverTimestamp(),
        if (foodImageUrl != null) 'foodImage': foodImageUrl,
      };

      final menuRef = FirebaseFirestore.instance
          .collection('messes')
          .doc(widget.messId)
          .collection('menu');

      if (widget.menuId != null) {
        // Update existing
        await menuRef.doc(widget.menuId).update(menuItem);
      } else {
        // Add new
        await menuRef.add({
          ...menuItem,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.menuId != null
                ? "Item updated successfully ✅"
                : "Item added successfully ✅",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, menuItem);
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Menu Item" : "Add Menu Item"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Item Name
            AuthField(
              hintText: "Item Name",
              icon: Icons.fastfood,
              controller: _nameController,
            ),
            const SizedBox(height: 16),

            // Price
            AuthField(
              hintText: "Price (₹)",
              icon: Icons.currency_rupee,
              controller: _priceController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Description
            AuthField(
              hintText: "Description",
              icon: Icons.description,
              controller: _descriptionController,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      (widget.menuId == null && _foodImage == null)
                          ? Colors.red
                          : const Color.fromARGB(255, 27, 84, 78),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                children: [
                  if (_foodImage != null) ...{
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_foodImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  } else if (isEditing && widget.existingImageUrl != null) ...{
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.existingImageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  } else ...{
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 12),
                  },
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showImageSourceDialog,
                    icon: const Icon(Icons.image),
                    label: Text(
                      _foodImage == null && !isEditing
                          ? 'Upload Food Image'
                          : 'Change Image',
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: const Color.fromARGB(255, 27, 84, 78),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.menuId == null && _foodImage == null)
                    const Text(
                      '* Required Field',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isEditing && _foodImage == null)
                    Text(
                      'Click to update image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Veg / Non-Veg / Jain
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  RadioListTile(
                    title: const Text("Veg"),
                    value: "Veg",
                    groupValue: _type,
                    onChanged: (value) => setState(() => _type = value!),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(vertical: -4),
                  ),
                  RadioListTile(
                    title: const Text("Non-Veg"),
                    value: "Non-Veg",
                    groupValue: _type,
                    onChanged: (value) => setState(() => _type = value!),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(vertical: -4),
                  ),
                  RadioListTile(
                    title: const Text("Jain"),
                    value: "Jain",
                    groupValue: _type,
                    onChanged: (value) => setState(() => _type = value!),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(vertical: -4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Save / Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor:
                      isEditing ? Colors.orange.shade600 : Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black54,
                  disabledBackgroundColor: Colors.grey,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          isEditing ? "Save Changes" : "Add Item",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
