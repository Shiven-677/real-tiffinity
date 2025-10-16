import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/views/widgets/items_ordered_widget.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isCompleting = false;

  Future<Map<String, dynamic>?> _fetchCustomerDetails() async {
    try {
      final customerId = widget.orderData['customerId'];
      if (customerId == null) return null;

      final customerDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(customerId)
              .get();

      if (customerDoc.exists) {
        return customerDoc.data();
      }
    } catch (e) {
      debugPrint('Error fetching customer details: $e');
    }
    return null;
  }

  Future<void> _markAsCompleted() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': 'Completed'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.orderData['status'] ?? 'Pending';
    final isPending = status.toLowerCase() == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderData['orderId'] ?? ''}'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchCustomerDetails(),
        builder: (context, snapshot) {
          final customerData = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Status Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isPending
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isPending ? Icons.access_time : Icons.check_circle,
                        size: 60,
                        color: isPending ? Colors.amber[800] : Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.amber[800] : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Order Details Card (removed Address and Payment Status)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Order ID',
                            widget.orderData['orderId'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Customer Name',
                            customerData?['name'] ??
                                widget.orderData['customerEmail'] ??
                                'N/A',
                          ),
                          _buildInfoRow(
                            'Phone',
                            customerData?['phone'] ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Email',
                            widget.orderData['customerEmail'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Order Bill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Order Bill',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        OrderBill(
                          items: List<Map<String, dynamic>>.from(
                            widget.orderData['items'] ?? [],
                          ),
                          status: widget.orderData['paymentStatus'] ?? 'Unpaid',
                          compact: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Complete Order Slider
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Text(
                          'Slide to mark as completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SlideToComplete(
                          onCompleted: _markAsCompleted,
                          isLoading: _isCompleting,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class SlideToComplete extends StatefulWidget {
  final VoidCallback onCompleted;
  final bool isLoading;

  const SlideToComplete({
    super.key,
    required this.onCompleted,
    this.isLoading = false,
  });

  @override
  State<SlideToComplete> createState() => _SlideToCompleteState();
}

class _SlideToCompleteState extends State<SlideToComplete> {
  double _dragPosition = 0.0;
  static const double _threshold = 0.85;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final buttonSize = 60.0;
    final maxDrag = screenWidth - buttonSize - 8;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              _dragPosition / maxDrag > _threshold
                  ? 'Release to Complete'
                  : 'Slide to Complete →',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition = (_dragPosition + details.delta.dx).clamp(
                    0.0,
                    maxDrag,
                  );
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragPosition / maxDrag > _threshold && !widget.isLoading) {
                  widget.onCompleted();
                } else {
                  setState(() {
                    _dragPosition = 0.0;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    widget.isLoading
                        ? const Padding(
                          padding: EdgeInsets.all(15),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
