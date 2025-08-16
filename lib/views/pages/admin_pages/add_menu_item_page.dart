import 'dart:io';
import 'package:Tiffinity/views/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuItemPage extends StatefulWidget {
  final Map<String, dynamic>? existingItem; // optional for editing

  const AddMenuItemPage({super.key, this.existingItem});

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = "Veg";
  File? _image;

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill the form
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!['name'];
      _priceController.text = widget.existingItem!['price'].toString();
      _descriptionController.text = widget.existingItem!['description'] ?? '';
      _type = widget.existingItem!['type'];
      _image = widget.existingItem!['image'] as File?;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveItem() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please pick an image")));
      return;
    }

    Navigator.pop(context, {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'description': _descriptionController.text,
      'type': _type,
      'image': _image,
    });
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
            AuthField(
              hintText: "Item Name",
              icon: Icons.fastfood,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            AuthField(
              hintText: "Price",
              icon: Icons.currency_rupee,
              controller: _priceController,
            ),
            const SizedBox(height: 16),
            AuthField(
              hintText: "Description",
              icon: Icons.description,
              controller: _descriptionController,
            ),
            const SizedBox(height: 16),

            // Veg / Non-Veg / Jain
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<String>(
                  title: const Text("Veg"),
                  value: "Veg",
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Non-Veg"),
                  value: "Non-Veg",
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Jain"),
                  value: "Jain",
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pick single image
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined, size: 20),
                label: const Text("Pick Image", style: TextStyle(fontSize: 14)),
              ),
            ),

            const SizedBox(height: 10),

            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 30),

            // Save / Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveItem,
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
                ),
                child: Text(
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
}
