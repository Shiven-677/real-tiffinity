import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/views/widgets/card_widget.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: 'Search for mess or tiffin services',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 8.0),

          // Messes list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('messes')
                      .snapshots(), // ✅ Remove the .where() filter initially
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messes available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter messes by online status and search query
                final messes =
                    snapshot.data!.docs.where((doc) {
                      final mess = doc.data() as Map<String, dynamic>?;

                      if (mess == null) return false;

                      // ✅ Check if isOnline field exists and is true
                      final isOnline = mess['isOnline'] == true;
                      if (!isOnline) return false;

                      // ✅ Search filter with null safety
                      if (searchQuery.isEmpty) return true;

                      final name =
                          (mess['messName'] ?? '').toString().toLowerCase();
                      final description =
                          (mess['description'] ?? '').toString().toLowerCase();

                      return name.contains(searchQuery) ||
                          description.contains(searchQuery);
                    }).toList();

                if (messes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No messes online right now',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: messes.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final messDoc = messes[index];
                    final mess = messDoc.data() as Map<String, dynamic>? ?? {};

                    return CardWidget(
                      title: mess['messName'] ?? 'Unnamed',
                      description: mess['description'] ?? 'No description',
                      ratings: '4.5', // You can add ratings field later
                      distance: '1.0', // You can calculate distance later
                      isVeg:
                          (mess['messType'] ?? 'Veg')
                              .toString()
                              .toLowerCase() ==
                          'veg',
                      messId: messDoc.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
