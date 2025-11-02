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
  String? _selectedReason;
  final List<String> rejectionReasons = [
    'Pickup time is too late',
    'Out of stock / Just sold out',
    'Quantity not available',
    'Other',
  ];

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

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Reject Order',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    rejectionReasons.map((reason) {
                      return RadioListTile(
                        title: Text(reason),
                        value: reason,
                        groupValue: _selectedReason,
                        onChanged: (val) {
                          setDialogState(() => _selectedReason = val);
                          // Also update parent state so button color changes
                          setState(() {});
                        },
                      );
                    }).toList(),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    _selectedReason = null;
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed:
                      _selectedReason == null
                          ? null
                          : () async {
                            Navigator.of(context).pop();
                            await _rejectOrder();
                          },
                  child: const Text('Reject'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _rejectOrder() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rejection reason'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading dialog with animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(width: 16),
                Text(
                  'Rejecting order...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
    );

    try {
      // Get the mess ID from the order data
      final messId = widget.orderData['messId'];

      // Update order status to Rejected
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'status': 'Rejected',
            'rejectionReason': _selectedReason,
            'rejectedAt': FieldValue.serverTimestamp(),
          });

      // Increment rejected count in mess document
      if (messId != null) {
        await FirebaseFirestore.instance
            .collection('messes')
            .doc(messId)
            .update({'rejectedCount': FieldValue.increment(1)});
      }

      if (mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show success snackbar with animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Order rejected successfully!'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back to mess home page
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // Pop twice: once for OrderDetailsPage, once to ensure we're back at home
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error rejecting order: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _acceptOrder() async {
    // Show loading dialog with animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(width: 16),
                Text(
                  'Accepting order...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
    );

    try {
      final messId = widget.orderData['messId'];

      // Update order status to Accepted
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': 'Accepted'});

      // Increment accepted count in mess document
      if (messId != null) {
        await FirebaseFirestore.instance
            .collection('messes')
            .doc(messId)
            .update({'acceptedCount': FieldValue.increment(1)});
      }

      if (mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show success snackbar with animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Order accepted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back to mess home page after delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error accepting order: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.orderData['status'] ?? 'Pending';
    final isPending = status.toString().toLowerCase() == 'pending';
    final isAccepted = status.toString().toLowerCase() == 'accepted';
    final isRejected = status.toString().toLowerCase() == 'rejected';
    final rejectionReason = widget.orderData['rejectionReason'];
    final pickupTime = widget.orderData['pickupTime'] ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderData['orderId'] ?? ''}'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        // Customer details
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
                            : isAccepted
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isPending
                            ? Icons.access_time
                            : isAccepted
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 60,
                        color:
                            isPending
                                ? Colors.amber[800]
                                : isAccepted
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isPending
                                  ? Colors.amber[800]
                                  : isAccepted
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order Details Card with pickupTime after Email
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
                          _buildInfoRow(
                            'Pickup Time',
                            pickupTime,
                            mainColor: Colors.orange,
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

                // Accept/Reject buttons ONLY for Pending status
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            await _acceptOrder();
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showRejectDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),

                // Rejection reason card (after rejection)
                if (isRejected && rejectionReason != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      color: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Rejected',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reason: $rejectionReason',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Slider to mark complete ONLY when status is Accepted
                if (isAccepted)
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

  Widget _buildInfoRow(String label, String value, {Color? mainColor}) {
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
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: mainColor ?? Colors.black,
                fontWeight:
                    mainColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
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
