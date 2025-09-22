import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/data/constants.dart';

// Import the order tracking page
import 'order_tracking_page.dart';

class MenuPage extends StatefulWidget {
  final String messId;
  const MenuPage({super.key, required this.messId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = 'All';
  String searchQuery = '';

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
          body: CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: const Color.fromARGB(255, 27, 84, 78),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  ValueListenableBuilder<Map<String, CartItem>>(
                    valueListenable: cartNotifier,
                    builder: (context, cart, _) {
                      final itemCount = cart.values.fold<int>(
                        0,
                        (sum, item) => sum + item.quantity,
                      );
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                            onPressed: () => _showCartBottomSheet(context),
                          ),
                          if (itemCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color.fromARGB(255, 27, 84, 78),
                          const Color.fromARGB(
                            255,
                            27,
                            84,
                            78,
                          ).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background placeholder
                        Container(
                          color: const Color.fromARGB(
                            255,
                            27,
                            84,
                            78,
                          ).withOpacity(0.8),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Mess Info Section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mess Name
                      Text(
                        messData['messName']?.toString() ?? 'Restaurant Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Mess Type
                      Text(
                        messData['messType']?.toString() ?? 'Cuisine Type',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      // Rating and timing row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 14),
                                SizedBox(width: 2),
                                Text(
                                  '4.2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Open • Closes 10:30 PM',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Distance and delivery time
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '1.50 km',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '28 mins',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Search and Filter Section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search menu items...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[500],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Button
                      Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Filter',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Menu Items
              _buildMenuSections(),
            ],
          ),
          // Floating Cart Button
          floatingActionButton: ValueListenableBuilder<Map<String, CartItem>>(
            valueListenable: cartNotifier,
            builder: (context, cart, _) {
              if (cart.isEmpty) return const SizedBox.shrink();

              final itemCount = cart.values.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
              final totalAmount = cart.values.fold<double>(
                0.0,
                (sum, item) => sum + item.totalPrice,
              );

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: FloatingActionButton.extended(
                  onPressed: () => _showCartBottomSheet(context),
                  backgroundColor: const Color.fromARGB(255, 27, 84, 78),
                  label: SizedBox(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$itemCount items | ₹${totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'VIEW CART',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildMenuSections() {
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
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Text("No menu items available"),
              ),
            ),
          );
        }

        // Filter items based on search
        final allItems =
            snapshot.data!.docs.where((doc) {
              if (searchQuery.isEmpty) return true;
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name']?.toString().toLowerCase() ?? '';
              return name.contains(searchQuery);
            }).toList();

        // Group items by category
        final groupedItems = <String, List<DocumentSnapshot>>{};

        for (final doc in allItems) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category']?.toString() ?? 'Main Course';

          if (!groupedItems.containsKey(category)) {
            groupedItems[category] = [];
          }
          groupedItems[category]!.add(doc);
        }

        if (groupedItems.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Text("No items match your search"),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final categories = groupedItems.keys.toList();
            final category = categories[index];
            final categoryItems = groupedItems[category]!;

            return Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Category Items
                  ...categoryItems.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildMenuItem(doc.id, data);
                  }).toList(),
                ],
              ),
            );
          }, childCount: groupedItems.length),
        );
      },
    );
  }

  Widget _buildMenuItem(String itemId, Map<String, dynamic> data) {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: cartNotifier,
      builder: (context, cart, _) {
        final cartItem = cart[itemId];
        final quantity = cartItem?.quantity ?? 0;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Veg/Non-veg symbol
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child:
                    data['type']?.toString() == 'Veg'
                        ? Symbols.vegSymbol
                        : Symbols.nonVegSymbol,
              ),
              const SizedBox(width: 12),
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      data['name']?.toString() ?? 'Unknown Item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Text(
                      '₹ ${_getPrice(data['price'])}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    if (data['description'] != null &&
                        data['description'].toString().isNotEmpty) ...[
                      Text(
                        data['description'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          // Show full description
                        },
                        child: const Text(
                          'read more',
                          style: TextStyle(
                            color: Color.fromARGB(255, 27, 84, 78),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Add/Quantity Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          quantity > 0
                              ? Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 27, 84, 78),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _removeFromCart(itemId),
                                      icon: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 35,
                                        minHeight: 35,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _addToCart(itemId, data),
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 35,
                                        minHeight: 35,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      27,
                                      84,
                                      78,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _addToCart(itemId, data),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'ADD',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                27,
                                                84,
                                                78,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.add,
                                            color: Color.fromARGB(
                                              255,
                                              27,
                                              84,
                                              78,
                                            ),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Food Image placeholder
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey[400],
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPrice(dynamic price) {
    if (price == null) return '0';
    if (price is String) {
      return price;
    } else if (price is int || price is double) {
      return price.toString();
    }
    return '0';
  }

  double _getPriceAsDouble(dynamic price) {
    if (price == null) return 0.0;
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    } else if (price is int) {
      return price.toDouble();
    } else if (price is double) {
      return price;
    }
    return 0.0;
  }

  void _addToCart(String itemId, Map<String, dynamic> itemData) async {
    try {
      final messDoc =
          await FirebaseFirestore.instance
              .collection('messes')
              .doc(widget.messId)
              .get();
      final messData = messDoc.data() as Map<String, dynamic>?;

      final cart = Map<String, CartItem>.from(cartNotifier.value);

      if (cart.containsKey(itemId)) {
        cart[itemId]!.quantity++;
      } else {
        cart[itemId] = CartItem(
          id: itemId,
          name: itemData['name']?.toString() ?? 'Unknown',
          price: _getPriceAsDouble(itemData['price']),
          messId: widget.messId,
          messName: messData?['messName']?.toString() ?? 'Unknown Mess',
        );
      }

      cartNotifier.value = cart;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${itemData['name']?.toString() ?? 'Item'} added to cart',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error adding item to cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ValueListenableBuilder<Map<String, CartItem>>(
              valueListenable: cartNotifier,
              builder: (context, cart, _) {
                if (cart.isEmpty) {
                  return const Center(child: Text('Your cart is empty'));
                }

                final cartItems = cart.values.toList();
                final totalAmount = cartItems.fold<double>(
                  0.0,
                  (sum, item) => sum + item.totalPrice,
                );

                return Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Cart Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)} × ${item.quantity}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
                                '₹${totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 27, 84, 78),
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
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  27,
                                  84,
                                  78,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'PROCEED TO CHECKOUT',
                                style: TextStyle(
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
            ),
          ),
    );
  }

  void _checkout(double totalAmount) async {
    try {
      final messDoc =
          await FirebaseFirestore.instance
              .collection('messes')
              .doc(widget.messId)
              .get();
      final messData = messDoc.data() as Map<String, dynamic>?;

      // Generate order data
      final orderItems =
          cartNotifier.value.values.map((item) {
            return {
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'type': 'Veg', // You can determine this from your item data
            };
          }).toList();

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Order Confirmation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount: ₹${totalAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Your order will be processed and you will receive confirmation shortly.',
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
                    // Clear cart
                    cartNotifier.value = {};

                    // Close dialogs and menu page
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close cart bottom sheet
                    Navigator.pop(context); // Close menu page

                    // Navigate to order tracking
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => OrderTrackingPage(
                              orderId:
                                  'TIF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              orderItems: orderItems,
                              totalAmount: totalAmount,
                              messName:
                                  messData?['messName']?.toString() ??
                                  'Restaurant',
                              messAddress:
                                  messData?['address']?.toString() ??
                                  'Address not available',
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 27, 84, 78),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      print('Error during checkout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
