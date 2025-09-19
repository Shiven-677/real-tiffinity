import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/views/widgets/card_widget.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('messes')
                      .where('isOnline', isEqualTo: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No messes online right now"),
                  );
                }

                final messes =
                    snapshot.data!.docs.where((doc) {
                      final mess = doc.data() as Map<String, dynamic>;
                      final name =
                          (mess['messName'] ?? '').toString().toLowerCase();
                      final description =
                          (mess['description'] ?? '').toString().toLowerCase();

                      return name.contains(searchQuery) ||
                          description.contains(searchQuery);
                    }).toList();

                if (messes.isEmpty) {
                  return const Center(child: Text("No results found"));
                }

                return ListView.builder(
                  itemCount: messes.length,
                  itemBuilder: (context, index) {
                    final mess = messes[index].data() as Map<String, dynamic>;

                    return CardWidget(
                      title: mess['messName'] ?? 'Unnamed',
                      description: mess['description'] ?? '',
                      ratings: "4.5",
                      distance: "1.0",
                      isVeg: mess['messType']?.toLowerCase() == 'veg',
                      messId: messes[index].id, // Pass the mess ID here
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
