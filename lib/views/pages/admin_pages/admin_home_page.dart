import 'package:Tiffinity/views/pages/admin_pages/admin_setup_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Tiffinity/views/pages/admin_pages/order_details_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State {
  String? _messId;
  String _selectedStatus = "All";
  String _searchQuery = "";
  Map<String, String> _customerNames = {};

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

  Future<String> _fetchCustomerName(String customerId) async {
    if (_customerNames.containsKey(customerId)) {
      return _customerNames[customerId]!;
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(customerId)
              .get();
      if (userDoc.exists) {
        final name = userDoc.data()?['name'] ?? 'Customer';
        _customerNames[customerId] = name;
        return name;
      }
    } catch (e) {
      debugPrint('Error fetching customer name: $e');
    }

    return 'Customer';
  }

  Future<void> _toggleOnlineStatus(bool status) async {
    try {
      await FirebaseFirestore.instance.collection('messes').doc(_messId).update(
        {'isOnline': status},
      );
    } catch (e) {
      debugPrint('Error toggling status: $e');
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
              title: const Text("Accepted"),
              onTap: () {
                _applyFilter("Accepted");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text("Completed"),
              onTap: () {
                _applyFilter("Completed");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("Rejected"),
              onTap: () {
                _applyFilter("Rejected");
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_mall_directory, color: Colors.grey, size: 80),
              SizedBox(height: 16),
              Text(
                'No mess found for your admin account.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Create Mess'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AdminSetupPage(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Mess Status Section
              StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('messes')
                        .doc(_messId)
                        .snapshots(),
                builder: (context, snapshot) {
                  bool isOnline = snapshot.data?['isOnline'] ?? false;
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isOnline
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isOnline
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isOnline ? Icons.store : Icons.store_mall_directory,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOnline ? "Mess Open" : "Mess Closed",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOnline
                                    ? "Orders are receivable"
                                    : "Orders are stopped",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isOnline,
                          onChanged: _toggleOnlineStatus,
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green.shade300,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.red.shade300,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Summary Card with Color Coding
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('orders')
                        .where('messId', isEqualTo: _messId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final orders = snapshot.data!.docs;
                  final totalOrders = orders.length;
                  final completed =
                      orders
                          .where(
                            (doc) =>
                                (doc.data()
                                    as Map<String, dynamic>)['status'] ==
                                'Completed',
                          )
                          .length;
                  final accepted =
                      orders
                          .where(
                            (doc) =>
                                (doc.data()
                                    as Map<String, dynamic>)['status'] ==
                                'Accepted',
                          )
                          .length;
                  final rejected =
                      orders
                          .where(
                            (doc) =>
                                (doc.data()
                                    as Map<String, dynamic>)['status'] ==
                                'Rejected',
                          )
                          .length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Total Orders Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                totalOrders.toString(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Total Orders',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Summary Row with 3 cards
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      completed.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Completed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      accepted.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Accepted',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      rejected.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Rejected',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: _filterOrders,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterOptions,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Orders List
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

                      final status = order['status'] ?? 'Accepted';
                      final customerId = order['customerId'];

                      // Color coding based on status
                      Color statusColor = Colors.orange;
                      Color statusBgColor = Colors.orange.withOpacity(0.2);
                      IconData statusIcon = Icons.schedule;

                      if (status == 'Completed') {
                        statusColor = Colors.green;
                        statusBgColor = Colors.green.withOpacity(0.2);
                        statusIcon = Icons.check_circle;
                      } else if (status == 'Rejected') {
                        statusColor = Colors.red;
                        statusBgColor = Colors.red.withOpacity(0.2);
                        statusIcon = Icons.cancel;
                      }

                      return FutureBuilder<String>(
                        future: _fetchCustomerName(customerId),
                        builder: (context, nameSnapshot) {
                          final customerName =
                              nameSnapshot.data ?? 'Loading...';
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OrderDetailsPage(
                                        orderId: order['orderId'],
                                        orderData: order,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: statusBgColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order #${order['orderId'] ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            customerName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                formattedTime,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBgColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
