import 'package:flutter/material.dart';
import 'package:Tiffinity/data/constants.dart';
import 'order_tracking_page.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  // Mock orders data
  final List<Map<String, dynamic>> orders = [
    {
      'orderId': 'TIF12345',
      'messName': 'Juis Homemade Food',
      'status': 'Being Prepared',
      'items': [
        {'name': 'Poha', 'quantity': 2, 'price': 70, 'type': 'Veg'},
        {'name': 'Upma', 'quantity': 1, 'price': 80, 'type': 'Veg'},
      ],
      'totalAmount': 220.0,
      'orderTime': '9:15 PM',
      'estimatedDelivery': '9:45 PM',
      'messAddress': 'FC Road, Pune',
      'isActive': true,
    },
    {
      'orderId': 'TIF12344',
      'messName': 'Mumbai Tiffin Center',
      'status': 'Delivered',
      'items': [
        {'name': 'Dal Rice', 'quantity': 1, 'price': 120, 'type': 'Veg'},
        {'name': 'Roti', 'quantity': 4, 'price': 60, 'type': 'Veg'},
      ],
      'totalAmount': 180.0,
      'orderTime': 'Yesterday, 1:30 PM',
      'estimatedDelivery': 'Yesterday, 2:00 PM',
      'messAddress': 'Kothrud, Pune',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          orders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(order);
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
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
            'Your order history will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (order['isActive']) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => OrderTrackingPage(
                      orderId: order['orderId'],
                      orderItems: List<Map<String, dynamic>>.from(
                        order['items'],
                      ),
                      totalAmount: order['totalAmount'],
                      messName: order['messName'],
                      messAddress: order['messAddress'],
                    ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['messName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order['orderId']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        color: _getStatusColor(order['status']),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Order items
              ...order['items'].take(2).map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              item['type'] == 'Veg' ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['type'] == 'Veg'
                              ? Icons.eco
                              : Icons.lunch_dining,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item['name']} × ${item['quantity']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (order['items'].length > 2)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    '+${order['items'].length - 2} more items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Order footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${order['totalAmount'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 27, 84, 78),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ordered at ${order['orderTime']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  if (order['isActive'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 27, 84, 78),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Track Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        // Reorder functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Items added to cart for reorder'),
                          ),
                        );
                      },
                      child: const Text(
                        'Reorder',
                        style: TextStyle(
                          color: Color.fromARGB(255, 27, 84, 78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'being prepared':
        return Colors.orange;
      case 'out for delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return const Color.fromARGB(255, 27, 84, 78);
    }
  }
}
