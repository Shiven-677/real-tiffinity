import 'package:flutter/material.dart';

class OrderBill extends StatelessWidget {
  final List<Map<String, dynamic>> items; // Each item: {no, qty, name, price}
  final String status; // "PAID" or "UNPAID"
  final bool compact; // new: render a compact version for lists

  const OrderBill({
    super.key,
    required this.items,
    required this.status,
    this.compact = false,
  });

  double _calculateGrandTotal() {
    return items.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = _calculateGrandTotal();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Item No.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Qty.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Item Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Total",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Table Items
            ...items.map((item) {
              final total = item['qty'] * item['price'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text(item['no'].toString())),
                    Expanded(flex: 1, child: Text(item['qty'].toString())),
                    Expanded(flex: 3, child: Text(item['name'].toString())),
                    Expanded(flex: 2, child: Text("₹${item['price']}")),
                    Expanded(flex: 2, child: Text("₹$total")),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 8),
            const Divider(thickness: 1),

            // Grand Total
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Grand Total: ₹$grandTotal",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Status
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Status: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          status.toUpperCase() == "PAID"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
how to pass parameters

OrderBill(
  items: [
    {"no": 1, "qty": 2, "name": "Paneer Butter Masala", "price": 250},
    {"no": 2, "qty": 1, "name": "Garlic Naan", "price": 50},
  ],
  status: "PAID",
)


*/
