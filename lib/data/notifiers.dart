// ValueNotifier: hold the data
// ValueListenableBuilder: listen to data changes (dont need to use setState)
import 'package:flutter/material.dart';

ValueNotifier<int> customerSelectedPageNotifier = ValueNotifier(0);
ValueNotifier<int> adminSelectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);

// Cart management
ValueNotifier<Map<String, CartItem>> cartNotifier = ValueNotifier({});

class CartItem {
  final String id;
  final String name;
  final double price;
  final String messId;
  final String messName;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.messId,
    required this.messName,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}
