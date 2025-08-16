import 'package:flutter/material.dart';
import 'items_ordered_widget.dart';

class OrderWidget extends StatelessWidget {
  final String orderNumber;
  final String customerName;
  final String orderStatus; // Pending / Completed
  final String paymentStatus; // Paid / Unpaid
  final String time;
  final List<Map<String, dynamic>> items; // bill items

  const OrderWidget({
    super.key,
    required this.orderNumber,
    required this.customerName,
    required this.orderStatus,
    required this.paymentStatus,
    required this.time,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number
            Text(
              "Order #$orderNumber",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),

            // Customer Name & Outer Order Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        orderStatus.toLowerCase() == 'pending'
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    orderStatus.toUpperCase(),
                    style: TextStyle(
                      color:
                          orderStatus.toLowerCase() == 'pending'
                              ? Colors.amber[800]
                              : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Full Bill Section
            OrderBill(
              items: items,
              status: paymentStatus, // <- inner bill still uses Paid/Unpaid
              compact: false,
            ),
            const SizedBox(height: 6),

            // Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
