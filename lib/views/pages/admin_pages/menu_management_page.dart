import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_menu_item_page.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  String? _messId;

  @override
  void initState() {
    super.initState();
    _fetchMessId();
  }

  Future<void> _fetchMessId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final messSnapshot =
        await FirebaseFirestore.instance
            .collection("messes")
            .where("ownerId", isEqualTo: uid)
            .limit(1)
            .get();

    if (messSnapshot.docs.isNotEmpty) {
      setState(() {
        _messId = messSnapshot.docs.first.id;
      });
    }
  }

  void _addMenuItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMenuItemPage(messId: _messId!)),
    );
  }

  void _editMenuItem(String menuId, Map<String, dynamic> itemData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddMenuItemPage(
              messId: _messId!,
              menuId: menuId,
              existingItem: itemData,
            ),
      ),
    );
  }

  void _deleteMenuItem(String menuId) async {
    await FirebaseFirestore.instance
        .collection("messes")
        .doc(_messId)
        .collection("menu")
        .doc(menuId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    if (_messId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("messes")
                .doc(_messId)
                .collection("menu")
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nothing to display"));
          }

          final menuItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final doc = menuItems[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "₹${data['price']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editMenuItem(doc.id, data),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteMenuItem(doc.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Type: ${data['type']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (data['description'] != null &&
                          data['description'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMenuItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
