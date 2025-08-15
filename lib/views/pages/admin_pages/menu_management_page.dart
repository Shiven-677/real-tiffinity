import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_menu_item_page.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  List<Map<String, dynamic>> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _saveMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsToSave = _menuItems.map((item) {
      return {
        'name': item['name'],
        'price': item['price'],
        'type': item['type'],
        'images':
            (item['images'] as List<File>).map((file) => file.path).toList(),
      };
    }).toList();
    prefs.setString('menu_items', jsonEncode(itemsToSave));
  }

  Future<void> _loadMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('menu_items');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        _menuItems = decoded.map((item) {
          return {
            'name': item['name'],
            'price': item['price'],
            'type': item['type'],
            'images':
                (item['images'] as List).map((path) => File(path)).toList(),
          };
        }).toList();
      });
    }
  }

  void _addMenuItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMenuItemPage()),
    );
    if (newItem != null) {
      setState(() {
        _menuItems.add(newItem);
      });
      _saveMenuItems();
    }
  }

  void _editMenuItem(int index) async {
    final editedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMenuItemPage(existingItem: _menuItems[index]),
      ),
    );
    if (editedItem != null) {
      setState(() {
        _menuItems[index] = editedItem;
      });
      _saveMenuItems();
    }
  }

  void _deleteMenuItem(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
    _saveMenuItems();
  }

  void _openImagePreview(List<File> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Current items: ${_menuItems.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      size: 30, color: Colors.green),
                  onPressed: _addMenuItem,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_menuItems.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Nothing to display",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final List<File> images =
                        (item['images'] ?? []).cast<File>();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "₹${item['price']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => _editMenuItem(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteMenuItem(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Type: ${item['type']}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (images.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  itemBuilder: (context, imgIndex) {
                                    return GestureDetector(
                                      onTap: () => _openImagePreview(
                                          images, imgIndex),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        child: Image.file(
                                          images[imgIndex],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
