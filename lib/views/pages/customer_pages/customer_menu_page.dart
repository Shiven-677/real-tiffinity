import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/data/notifiers.dart';

class MenuPage extends StatefulWidget {
  final String messId;

  const MenuPage({super.key, required this.messId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("messes")
              .doc(widget.messId)
              .snapshots(),
      builder: (context, messSnapshot) {
        if (!messSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final messData = messSnapshot.data!.data() as Map<String, dynamic>?;

        if (messData == null) {
          return const Scaffold(body: Center(child: Text("Mess not found")));
        }

        return ValueListenableBuilder(
          valueListenable: customerSelectedPageNotifier,
          builder: (context, selectedPage, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  messData['messName'] ?? 'Mess',
                  style: const TextStyle(color: Colors.black),
                ),
                iconTheme: const IconThemeData(color: Colors.black),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.black),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Timings"),
                              content: Text(
                                "Opens: ${messData['openTime'] ?? 'N/A'}\n"
                                "Closes: ${messData['closeTime'] ?? 'N/A'}",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mess details section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messData['messName'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          messData['address'] ?? 'Address not available',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Menu or Cart depending on selected nav
                  Expanded(
                    child:
                        selectedPage == 0 ? _buildMenuList() : _buildCartPage(),
                  ),
                ],
              ),

              // Bottom NavBar
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedPage,
                onDestinationSelected: (value) {
                  customerSelectedPageNotifier.value = value;
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.menu_book),
                    label: 'Menu',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Cart',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("messes")
              .doc(widget.messId)
              .collection("menu")
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No menu items available"));
        }

        final menuItems = snapshot.data!.docs;

        return ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final data = menuItems[index].data() as Map<String, dynamic>;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side: name + price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${data['price']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    // Add button
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${data['name']} added to cart (static)",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartPage() {
    return const Center(child: Text("Cart page (static for now)"));
  }
}
