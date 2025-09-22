import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/data/notifiers.dart';

class MenuPage extends StatefulWidget {
  final String messId;
  const MenuPage({super.key, required this.messId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedTab = 0; // 0 = Menu, 1 = Cart

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("messes")
              .doc(widget.messId)
              .snapshots(),
      builder: (context, messSnapshot) {
        if (!messSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final messData = messSnapshot.data!.data() as Map<String, dynamic>?;
        if (messData == null) {
          return const Scaffold(body: Center(child: Text("Mess not found")));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            title: Text(messData['messName'] ?? 'Menu'),
            actions: [
              ValueListenableBuilder<Map<String, CartItem>>(
                valueListenable: cartNotifier,
                builder: (context, cart, _) {
                  final itemCount = cart.values.fold(
                    0,
                    (sum, item) => sum + item.quantity,
                  );
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          setState(() {
                            selectedTab = 1; // Switch to cart tab
                          });
                        },
                      ),
                      if (itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Mess Info Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      messData['messName'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            messData['address'] ?? 'Address not available',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    if (messData['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        messData['description'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child:
                    selectedTab == 0
                        ? _buildMenuList(messData)
                        : _buildCartPage(),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedTab,
            onDestinationSelected: (value) {
              setState(() {
                selectedTab = value;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuList(Map<String, dynamic> messData) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("messes")
              .doc(widget.messId)
              .collection("menu")
              .orderBy('name')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No menu items available"));
        }

        final menuItems = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final doc = menuItems[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildMenuItem(doc.id, data, messData);
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    String itemId,
    Map<String, dynamic> data,
    Map<String, dynamic> messData,
  ) {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: cartNotifier,
      builder: (context, cart, _) {
        final cartItem = cart[itemId];
        final quantity = cartItem?.quantity ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Item Type Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getItemTypeColor(data['type']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getItemTypeIcon(data['type']),
                    color: _getItemTypeColor(data['type']),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown Item',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (data['description'] != null &&
                          data['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          data['description'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '₹${data['price'] ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity Controls
                if (quantity > 0) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _removeFromCart(itemId),
                          icon: const Icon(Icons.remove, color: Colors.white),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _addToCart(itemId, data, messData),
                          icon: const Icon(Icons.add, color: Colors.white),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => _addToCart(itemId, data, messData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartPage() {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: cartNotifier,
      builder: (context, cart, _) {
        if (cart.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add items from the menu to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final cartItems = cart.values.toList();
        final totalAmount = cartItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${item.price} × ${item.quantity}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _removeFromCart(item.id),
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      () => _addToCart(
                                        item.id,
                                        {
                                          'name': item.name,
                                          'price': item.price,
                                        },
                                        {'messName': item.messName},
                                      ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Checkout Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _checkout(totalAmount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Checkout (${cartItems.length} items)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(
    String itemId,
    Map<String, dynamic> itemData,
    Map<String, dynamic> messData,
  ) {
    final cart = Map<String, CartItem>.from(cartNotifier.value);

    if (cart.containsKey(itemId)) {
      cart[itemId]!.quantity++;
    } else {
      cart[itemId] = CartItem(
        id: itemId,
        name: itemData['name'] ?? 'Unknown',
        price: (itemData['price'] ?? 0).toDouble(),
        messId: widget.messId,
        messName: messData['messName'] ?? 'Unknown Mess',
      );
    }

    cartNotifier.value = cart;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${itemData['name']} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(String itemId) {
    final cart = Map<String, CartItem>.from(cartNotifier.value);

    if (cart.containsKey(itemId)) {
      if (cart[itemId]!.quantity > 1) {
        cart[itemId]!.quantity--;
      } else {
        cart.remove(itemId);
      }
      cartNotifier.value = cart;
    }
  }

  void _checkout(double totalAmount) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Checkout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                const Text(
                  'Order will be processed and you will receive confirmation shortly.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Clear cart after successful checkout
                  cartNotifier.value = {};
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to home
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order placed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Color _getItemTypeColor(String? type) {
    switch (type) {
      case 'Veg':
        return Colors.green;
      case 'Non-Veg':
        return Colors.red;
      case 'Jain':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemTypeIcon(String? type) {
    switch (type) {
      case 'Veg':
        return Icons.eco;
      case 'Non-Veg':
        return Icons.lunch_dining;
      case 'Jain':
        return Icons.self_improvement;
      default:
        return Icons.restaurant;
    }
  }
}
