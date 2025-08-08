import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  final String customerName;
  final String itemName;
  final String status;

  const OrderWidget({
    Key? key,
    required this.customerName,
    required this.itemName,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(itemName),
        trailing: Text(status, style: TextStyle(
          color: status.toLowerCase() == 'pending' ? Colors.orange : Colors.green,
        )),
      ),
    );
  }
}
