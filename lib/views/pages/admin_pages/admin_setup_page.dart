import 'package:Tiffinity/views/pages/admin_pages/admin_widget_tree.dart';
import 'package:Tiffinity/views/widgets/auth_field.dart'; // import your AuthField
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupPage extends StatefulWidget {
  final String userId;
  const AdminSetupPage({super.key, required this.userId});

  @override
  State<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  final messNameController = TextEditingController();
  final addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveMessDetails() async {
    if (messNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      _showError("Please fill all fields");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('messes')
          .doc(widget.userId)
          .set({
            'messName': messNameController.text.trim(),
            'address': addressController.text.trim(),
            'isOnline': false, // default offline
            'ownerId': widget.userId,
            'createdAt': FieldValue.serverTimestamp(),
          });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminWidgetTree()),
        (route) => false,
      );
    } catch (e) {
      _showError("Failed to save details");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Setup Mess.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),

                AuthField(
                  hintText: "Mess Name",
                  icon: Icons.store,
                  controller: messNameController,
                ),
                const SizedBox(height: 16),

                AuthField(
                  hintText: "Address",
                  icon: Icons.location_on,
                  controller: addressController,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMessDetails,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Save & Continue"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
