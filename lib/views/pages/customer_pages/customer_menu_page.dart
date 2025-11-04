import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/services/notification_service.dart';
import 'package:Tiffinity/views/widgets/checkout_login_dialog.dart';
import 'order_tracking_page.dart';
import 'package:Tiffinity/utils/order_id_generator.dart';

class MenuPage extends StatefulWidget {
  final String messId;

  const MenuPage({super.key, required this.messId});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = 'All';
  String searchQuery = '';

  // GET CART FOR CURRENT MESS ONLY
  Map<String, CartItem> _getCurrentMessCart() {
    return Map.fromEntries(
      cartNotifier.value.entries.where(
        (entry) => entry.value.messId == widget.messId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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

        final messData = messSnapshot.data!.data() as Map?;
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
                      final messCart = _getCurrentMessCart();
                      final itemCount = messCart.values.fold(
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
                            onPressed: () => showCartBottomSheet(context),
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

              // ✅ MESS INFO SECTION - WITH DARK MODE
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
                        style: TextStyle(
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

              // ✅ SEARCH AND FILTER SECTION - WITH DARK MODE
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
                            style: TextStyle(color: Colors.black),
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

          // ✅ FLOATING CART BUTTON - NO BACKGROUND CONTAINER
          floatingActionButton: ValueListenableBuilder<Map<String, CartItem>>(
            valueListenable: cartNotifier,
            builder: (context, cart, _) {
              final messCart = _getCurrentMessCart();
              if (messCart.isEmpty) return const SizedBox.shrink();

              final itemCount = messCart.values.fold(
                0,
                (sum, item) => sum + item.quantity,
              );
              final totalAmount = messCart.values.fold(
                0.0,
                (sum, item) => sum + item.totalPrice,
              );

              return FloatingActionButton.extended(
                onPressed: () => showCartBottomSheet(context),
                backgroundColor: const Color.fromARGB(255, 27, 84, 78),
                elevation: 8,
                label: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
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
    return StreamBuilder(
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
              final data = doc.data() as Map;
              final name = data['name']?.toString().toLowerCase() ?? '';
              return name.contains(searchQuery);
            }).toList();

        // Group items by category
        final groupedItems = <String, List<QueryDocumentSnapshot>>{};
        for (final doc in allItems) {
          final data = doc.data() as Map;
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Category Items
                  ...categoryItems.map((doc) {
                    final data = doc.data() as Map;
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

  Widget _buildMenuItem(String itemId, Map data) {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: cartNotifier,
      builder: (context, cart, _) {
        final cartItem = cart[itemId];
        final quantity = cartItem?.quantity ?? 0;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          color: Colors.white,
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
                    Text(
                      data['name']?.toString() ?? 'Unknown Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      '₹ ${_getPrice(data['price'])}',
                      style: TextStyle(
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
                        onTap: () {},
                        child: Text(
                          'read more',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 27, 84, 78),
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

  void _addToCart(String itemId, Map itemData) async {
    try {
      final messDoc =
          await FirebaseFirestore.instance
              .collection('messes')
              .doc(widget.messId)
              .get();

      final messData = messDoc.data() as Map?;
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

  void showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ValueListenableBuilder<Map<String, CartItem>>(
              valueListenable: cartNotifier,
              builder: (context, cart, _) {
                final messCart = _getCurrentMessCart();
                if (messCart.isEmpty) {
                  return Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }

                final cartItems = messCart.values.toList();
                final totalAmount = cartItems.fold(
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Your Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                              color: Colors.white,
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)} each',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity controls
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      27,
                                      84,
                                      78,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _removeFromCart(item.id);
                                        },
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
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          final cart =
                                              Map<String, CartItem>.from(
                                                cartNotifier.value,
                                              );
                                          cart[item.id]!.quantity++;
                                          cartNotifier.value = cart;
                                        },
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
                                ),
                                const SizedBox(width: 12),

                                // Total price
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
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
                              Text(
                                'Total Amount:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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
                              onPressed: () {
                                Navigator.pop(context);
                                _showPickupTimeDialog(totalAmount);
                              },
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

  void _showPickupTimeDialog(double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PickupTimeDialog(
            onConfirm: (pickupTime) {
              checkout(totalAmount, pickupTime);
            },
          ),
    );
  }

  void checkout(double totalAmount, String pickupTime) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Require login
    if (currentUser == null) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => CheckoutLoginDialog(
                onLoginSuccess: () async {
                  // Close the dialog first
                  Navigator.of(ctx).pop();

                  // Option A: re-run checkout with same parameters
                  // Be careful to avoid infinite loops if login fails repeatedly.
                  await Future.delayed(const Duration(milliseconds: 200));
                  checkout(totalAmount, pickupTime); // reuse the same values
                },
              ),
        );
      }
      return;
    }

    // Collect cart items for this mess
    final currentCart = _getCurrentMessCart();
    if (currentCart.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      }
      return;
    }

    // 1) Resolve customer's display name
    String displayName = 'Customer';
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      final profileName = (userDoc.data()?['name'] as String?)?.trim();
      displayName =
          (profileName != null && profileName.isNotEmpty)
              ? profileName
              : (currentUser.displayName ?? 'Customer');
    } catch (_) {
      displayName = currentUser.displayName ?? 'Customer';
    }

    try {
      // 2) Read mess basic details (defensive fallbacks)
      final messDoc =
          await FirebaseFirestore.instance
              .collection('messes')
              .doc(widget.messId)
              .get();
      final messData = messDoc.data() ?? {};
      final messName = (messData['messName'] as String?) ?? 'Unknown Mess';
      final messPhone = (messData['phone'] as String?) ?? 'Not available';
      final messAddress = (messData['address'] as String?) ?? 'Not available';
      final messOwnerId = messData['ownerId'] as String?;

      // 3) Build order items array from cart
      final orderItems =
          currentCart.entries.map((e) {
            final item = e.value;
            return {
              'itemId': e.key,
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'total': item.price * item.quantity,
            };
          }).toList();

      // 4) Create order id and references
      final ordersCol = FirebaseFirestore.instance.collection('orders');
      final customOrderId =
          OrderIDGenerator.generateOrderID(); // Generate custom ID
      final orderRef = ordersCol.doc(customOrderId); // Use custom ID as doc ID
      final orderId = customOrderId;

      // 5) Persist order document
      await orderRef.set({
        'orderId': orderId,
        'messId': widget.messId,
        'messName': messName,
        'messOwnerId': messOwnerId,
        'messPhone': messPhone,
        'messAddress': messAddress,

        'customerId': currentUser.uid,
        'customerEmail': currentUser.email,
        'customerName': displayName, // ✅ store resolved name

        'items': orderItems,
        'totalAmount': totalAmount,
        'status': 'Pending',
        'paymentStatus': 'Unpaid',
        'pickupTime': pickupTime,
        'orderTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 6) Notify mess (uses customerName and your mipmap icon in service)
      await NotificationService().sendOrderNotificationToMess(
        messId: widget.messId,
        orderId: orderId, // ✅ real id
        customerName: displayName, // ✅ resolved name
        totalAmount: totalAmount,
      );

      // 7) Clear only this mess cart
      cartNotifier.value = {};
      if (mounted) {
        Navigator.pop(context); // close any bottom sheet/dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order placed: #$orderId')));
        // Optional: navigate to tracking
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingPage(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Order failed: $e')));
      }
    }
  }
}

// Pickup Time Dialog Widget
class PickupTimeDialog extends StatefulWidget {
  final Function(String) onConfirm;

  const PickupTimeDialog({super.key, required this.onConfirm});

  @override
  State<PickupTimeDialog> createState() => _PickupTimeDialogState();
}

class _PickupTimeDialogState extends State<PickupTimeDialog> {
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('When will you pick up?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please select your estimated pickup time',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 27, 84, 78),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime?.format(context) ?? 'Select time',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(
                    Icons.access_time,
                    color: Color.fromARGB(255, 27, 84, 78),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedTime == null
                  ? null
                  : () {
                    Navigator.pop(context);
                    widget.onConfirm(_selectedTime!.format(context));
                  },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
