// ValueNotifier: hold the data
// ValueListenableBuilder: listen to data changes (dont need to use setState)
import 'package:flutter/material.dart';

ValueNotifier<int> customerSelectedPageNotifier = ValueNotifier<int>(0);
ValueNotifier<int> adminSelectedPageNotifier = ValueNotifier<int>(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

// Cart management
ValueNotifier<Map<String, CartItem>> cartNotifier =
    ValueNotifier<Map<String, CartItem>>({});

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

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'messId': messId,
      'messName': messName,
      'quantity': quantity,
    };
  }

  // Create from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price:
          (map['price'] is String)
              ? double.tryParse(map['price']) ?? 0.0
              : (map['price']?.toDouble() ?? 0.0),
      messId: map['messId']?.toString() ?? '',
      messName: map['messName']?.toString() ?? '',
      quantity:
          (map['quantity'] is String)
              ? int.tryParse(map['quantity']) ?? 1
              : (map['quantity']?.toInt() ?? 1),
    );
  }
}
