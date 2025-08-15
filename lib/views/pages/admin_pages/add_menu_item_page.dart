import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuItemPage extends StatefulWidget {
  final Map<String, dynamic>? existingItem; // optional for editing

  const AddMenuItemPage({super.key, this.existingItem});

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _type = "Veg";
  List<File> _images = [];

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill the form
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!['name'];
      _priceController.text = widget.existingItem!['price'].toString();
      _type = widget.existingItem!['type'];
      _images = (widget.existingItem!['images'] as List<File>);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'type': _type,
        'images': _images,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existingItem != null ? "Edit Menu Item" : "Add Menu Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a name" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter a price" : null,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: "Type"),
                items: ["Veg", "Non-Veg"]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text("Pick Images"),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _images
                    .map((file) => Image.file(file, width: 80, height: 80))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text(widget.existingItem != null ? "Save Changes" : "Add Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
