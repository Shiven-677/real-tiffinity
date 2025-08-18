import 'package:Tiffinity/views/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMenuItemPage extends StatefulWidget {
  final Map<String, dynamic>? existingItem; // optional for editing
  final String messId; // ✅ required
  final String? menuId; // ✅ optional for editing

  const AddMenuItemPage({
    super.key,
    required this.messId,
    this.existingItem,
    this.menuId,
  });

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = "Veg";

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

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      final menuItem = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text,
        'type': _type,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final menuRef = FirebaseFirestore.instance
          .collection('messes')
          .doc(widget.messId)
          .collection('menu');

      if (widget.menuId != null) {
        // ✅ update existing
        await menuRef.doc(widget.menuId).update(menuItem);
      } else {
        // ✅ add new
        await menuRef.add({
          ...menuItem,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.menuId != null
                ? "Item updated successfully"
                : "Item added successfully",
          ),
        ),
      );

      Navigator.pop(context, menuItem);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
                  onChanged: (value) => setState(() => _type = value!),
                ),
                RadioListTile<String>(
                  title: const Text("Non-Veg"),
                  value: "Non-Veg",
                  groupValue: _type,
                  onChanged: (value) => setState(() => _type = value!),
                ),
                RadioListTile<String>(
                  title: const Text("Jain"),
                  value: "Jain",
                  groupValue: _type,
                  onChanged: (value) => setState(() => _type = value!),
                ),
              ],
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
