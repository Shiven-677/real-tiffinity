import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'add_menu_item_page.dart';
import 'package:photo_view/photo_view.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  final List<Map<String, dynamic>> _menuItems = [];

  void _addMenuItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMenuItemPage()),
    );

    if (newItem != null) {
      setState(() {
        _menuItems.add(newItem);
      });
    }
  }

  void _openImagePreview(List<File> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with count & add button
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
                  icon: const Icon(
                    Icons.add_circle,
                    size: 30,
                    color: Colors.green,
                  ),
                  onPressed: _addMenuItem,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Show "Nothing to display" if empty
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
                            // Name + Price
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
                                Text(
                                  "₹${item['price']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Type
                            Text(
                              "Type: ${item['type']}",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 8),

                            // Horizontal scroll for images
                            if (images.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  itemBuilder: (context, imgIndex) {
                                    return GestureDetector(
                                      onTap:
                                          () => _openImagePreview(
                                            images,
                                            imgIndex,
                                          ),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
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
