import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Tiffinity/views/widgets/order_widget.dart';
import 'package:Tiffinity/views/widgets/summary_card.dart';
import 'package:Tiffinity/views/widgets/search_filter_bar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? _messId;
  String _selectedStatus = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchMessId();
  }

  Future<void> _fetchMessId() async {
    try {
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
    } catch (e) {
      debugPrint('Error fetching mess ID: $e');
    }
  }

  void _filterOrders(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _applyFilter(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text("All"),
              onTap: () {
                _applyFilter("All");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Pending"),
              onTap: () {
                _applyFilter("Pending");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text("Being Prepared"),
              onTap: () {
                _applyFilter("Being Prepared");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text("Delivered"),
              onTap: () {
                _applyFilter("Delivered");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_messId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Summary Card with real-time data
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('orders')
                        .where('messId', isEqualTo: _messId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SummaryCard(
                      totalOrders: 0,
                      delivered: 0,
                      pending: 0,
                    );
                  }

                  final orders = snapshot.data!.docs;
                  final totalOrders = orders.length;
                  final delivered =
                      orders
                          .where(
                            (doc) =>
                                (doc.data()
                                    as Map<String, dynamic>)['status'] ==
                                'Delivered',
                          )
                          .length;
                  final pending =
                      orders
                          .where(
                            (doc) =>
                                (doc.data()
                                    as Map<String, dynamic>)['status'] ==
                                'Pending',
                          )
                          .length;

                  return SummaryCard(
                    totalOrders: totalOrders,
                    delivered: delivered,
                    pending: pending,
                  );
                },
              ),
              const SizedBox(height: 16),

              SearchFilterBar(
                onSearchChanged: _filterOrders,
                onFilterPressed: _showFilterOptions,
              ),
              const SizedBox(height: 10),

              // Real-time orders from Firebase
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('orders')
                        .where('messId', isEqualTo: _messId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No orders yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Orders from customers will appear here',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Apply filters
                  final filteredOrders =
                      snapshot.data!.docs.where((doc) {
                        final order = doc.data() as Map<String, dynamic>;
                        final matchesStatus =
                            _selectedStatus == "All" ||
                            order['status'] == _selectedStatus;
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            (order['customerEmail']?.toString().toLowerCase() ??
                                    '')
                                .contains(_searchQuery.toLowerCase()) ||
                            (order['orderId']?.toString().toLowerCase() ?? '')
                                .contains(_searchQuery.toLowerCase());
                        return matchesStatus && matchesSearch;
                      }).toList();

                  if (filteredOrders.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: Text(
                          'No orders match your filter',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final orderDoc = filteredOrders[index];
                      final order = orderDoc.data() as Map<String, dynamic>;

                      String formattedTime = '';
                      if (order['orderTime'] != null) {
                        final timestamp = order['orderTime'] as Timestamp;
                        final dateTime = timestamp.toDate();
                        formattedTime =
                            '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
                      }

                      return OrderWidget(
                        orderNumber: order['orderId'] ?? '',
                        customerName: order['customerEmail'] ?? 'Customer',
                        orderStatus: order['status'] ?? 'Pending',
                        paymentStatus: order['paymentStatus'] ?? 'Unpaid',
                        time: formattedTime,
                        items: List<Map<String, dynamic>>.from(
                          order['items'] ?? [],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
