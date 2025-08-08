import 'package:flutter/material.dart';
import 'package:practise/views/widgets/order_widget.dart';
import 'package:practise/views/widgets/summary_card.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  orders list inside build()
    final List<Map<String, String>> orders = [
      {
        'customerName': 'rohit gay',
        'item': 'Paneer Butter Masala',
        'status': 'Pending',
      },
      {
        'customerName': 'Jane Smith',
        'item': 'Veg Biryani',
        'status': 'Delivered',
      },
      {
        'customerName': 'Amit Sharma',
        'item': 'Roti with Dal',
        'status': 'Pending',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Step 1: Today's Summary Card
            SummaryCard(
              totalOrders: 120,
              delivered: 95,
              pending: 25,
            ),

            const SizedBox(height: 16),

            // Step 2: Orders List
            ListView.builder(
              shrinkWrap: true, // so it works inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderWidget(
                  customerName: order['customerName']!,
                  itemName: order['item']!,
                  status: order['status']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
