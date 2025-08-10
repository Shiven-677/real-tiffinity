import 'package:flutter/material.dart';
import 'package:Tiffinity/views/widgets/order_widget.dart';
import 'package:Tiffinity/views/widgets/summary_card.dart';
import 'package:Tiffinity/views/widgets/search_filter_bar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<Map<String, String>> _orders = [
    {
      'orderNumber': '0005',
      'customerName': 'Rohit Naik',
      'item': 'Paneer Butter Masala',
      'status': 'Pending',
      'time': '5:55'
    },
    {
      'orderNumber': '0007',
      'customerName': 'Dhevesh Pujari',
      'item': 'Veg Biryani',
      'status': 'Delivered',
      'time': '7:77'
    },
    {
      'orderNumber': '0001',
      'customerName': 'Modi',
      'item': 'Roti with Dal',
      'status': 'Pending',
      'time': '4:10'
    },
  ];

  late List<Map<String, String>> _filteredOrders;
  String _selectedStatus = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filteredOrders = List.from(_orders);
  }

  void _updateFilters() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesStatus =
            _selectedStatus == "All" || order['status'] == _selectedStatus;
        final matchesSearch = _searchQuery.isEmpty ||
            order['customerName']!.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
            order['item']!.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  void _filterOrders(String query) {
    _searchQuery = query;
    _updateFilters();
  }

  void _applyFilter(String status) {
    _selectedStatus = status;
    _updateFilters();
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
    return Scaffold(
      // Removed the appBar completely
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
             // Top icons row

              // Summary card
              SummaryCard(totalOrders: 120, delivered: 95, pending: 25),
              const SizedBox(height: 16),

              // Search + Filter bar
              SearchFilterBar(
                onSearchChanged: _filterOrders,
                onFilterPressed: _showFilterOptions,
              ),
              const SizedBox(height: 10),

              // Orders list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return OrderWidget(
                    orderNumber:
                        order['orderNumber'] ?? (index + 1).toString(),
                    customerName: order['customerName']!,
                    itemName: order['item']!,
                    status: order['status']!,
                    time: order['time'] ?? '',
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
