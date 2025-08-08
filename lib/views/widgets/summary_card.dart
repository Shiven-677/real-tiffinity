import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int totalOrders;
  final int delivered;
  final int pending;

  const SummaryCard({
    Key? key,
    required this.totalOrders,
    required this.delivered,
    required this.pending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Today's Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                    totalOrders.toString(), "Total Orders", Colors.orange),
                _buildSummaryItem(
                    delivered.toString(), "Delivered", Colors.green),
                _buildSummaryItem(
                    pending.toString(), "Pending", Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each summary item
  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
