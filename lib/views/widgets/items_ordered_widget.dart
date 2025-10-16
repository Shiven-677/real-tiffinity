import 'package:flutter/material.dart';

class OrderBill extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String status;
  final bool compact;

  const OrderBill({
    super.key,
    required this.items,
    required this.status,
    this.compact = false,
  });

  double _calculateGrandTotal() {
    return items.fold(0.0, (sum, item) {
      // Try both 'quantity' and 'qty' field names
      final qty = item['quantity'] ?? item['qty'] ?? 0;
      final price = item['price'] ?? 0.0;

      // Convert to double if int
      final qtyDouble = (qty is int) ? qty.toDouble() : (qty as double? ?? 0.0);
      final priceDouble =
          (price is int) ? price.toDouble() : (price as double? ?? 0.0);

      return sum + (qtyDouble * priceDouble);
    });
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = _calculateGrandTotal();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header (removed Item No.)
          Row(
            children: const [
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
            // Try both field names
            final qty = item['quantity'] ?? item['qty'] ?? 0;
            final price = item['price'] ?? 0.0;

            // Convert to proper types
            final qtyDouble =
                (qty is int) ? qty.toDouble() : (qty as double? ?? 0.0);
            final priceDouble =
                (price is int) ? price.toDouble() : (price as double? ?? 0.0);
            final total = qtyDouble * priceDouble;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text(qtyDouble.toInt().toString())),
                  Expanded(
                    flex: 3,
                    child: Text((item['name'] ?? '').toString()),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("₹${priceDouble.toStringAsFixed(0)}"),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("₹${total.toStringAsFixed(0)}"),
                  ),
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
              "Grand Total: ₹${grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
