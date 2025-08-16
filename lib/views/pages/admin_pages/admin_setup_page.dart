import 'package:Tiffinity/views/pages/admin_pages/admin_widget_tree.dart';
import 'package:Tiffinity/views/widgets/auth_field.dart';
import 'package:Tiffinity/views/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a timing slot
class TimeSlot {
  TextEditingController openingController;
  TextEditingController closingController;

  TimeSlot({String? opening, String? closing})
    : openingController = TextEditingController(text: opening),
      closingController = TextEditingController(text: closing);
}

class AdminSetupPage extends StatefulWidget {
  final String userId;
  const AdminSetupPage({super.key, required this.userId});

  @override
  State<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  final messNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  String _messType = "Veg";
  bool _isLoading = false;

  // List of time slots (first mandatory)
  List<TimeSlot> timeSlots = [TimeSlot()];

  Future<void> _saveMessDetails() async {
    if (messNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        timeSlots.any(
          (slot) =>
              slot.openingController.text.trim().isEmpty ||
              slot.closingController.text.trim().isEmpty,
        )) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<Map<String, String>> timings =
          timeSlots.map((slot) {
            return {
              "opening": slot.openingController.text,
              "closing": slot.closingController.text,
            };
          }).toList();

      await FirebaseFirestore.instance
          .collection('messes')
          .doc(widget.userId)
          .set({
            'messName': messNameController.text.trim(),
            'description': descriptionController.text.trim(),
            'messType': _messType,
            'address': addressController.text.trim(),
            'timings': timings,
            'isOnline': false,
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

  Widget _buildTimeField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          controller.text = time.format(context);
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(width: 3.0),
        ),
        contentPadding: const EdgeInsets.all(20.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Mess Details.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Mess Name
                      AuthField(
                        hintText: "Mess Name",
                        icon: Icons.store,
                        controller: messNameController,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      AuthField(
                        hintText: "Description",
                        icon: Icons.description,
                        controller: descriptionController,
                      ),
                      const SizedBox(height: 20),

                      // Mess Type (Vertical Radio Buttons)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            title: const Text(
                              "Veg",
                              style: TextStyle(fontSize: 18),
                            ),
                            value: "Veg",
                            groupValue: _messType,
                            onChanged:
                                (value) => setState(() => _messType = value!),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -4),
                          ),
                          RadioListTile<String>(
                            title: const Text(
                              "Non-Veg",
                              style: TextStyle(fontSize: 18),
                            ),
                            value: "Non-Veg",
                            groupValue: _messType,
                            onChanged:
                                (value) => setState(() => _messType = value!),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -4),
                          ),
                          RadioListTile<String>(
                            title: const Text(
                              "Both",
                              style: TextStyle(fontSize: 18),
                            ),
                            value: "Both",
                            groupValue: _messType,
                            onChanged:
                                (value) => setState(() => _messType = value!),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Timing Slots
                      Column(
                        children: [
                          // First slot (mandatory)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTimeField(
                                      timeSlots[0].openingController,
                                      "Opening Time",
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 2,
                                    color: Colors.grey.shade400,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                  Expanded(
                                    child: _buildTimeField(
                                      timeSlots[0].closingController,
                                      "Closing Time",
                                    ),
                                  ),
                                ],
                              ),
                              // + button aligned under first closing time
                              if (timeSlots.length == 1)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        timeSlots.add(TimeSlot());
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Second slot (optional)
                          if (timeSlots.length > 1)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTimeField(
                                        timeSlots[1].openingController,
                                        "Opening Time",
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 2,
                                      color: Colors.grey.shade400,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                    Expanded(
                                      child: _buildTimeField(
                                        timeSlots[1].closingController,
                                        "Closing Time",
                                      ),
                                    ),
                                  ],
                                ),
                                // Cancel button aligned under second closing time
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        timeSlots.removeAt(1);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Address
                      AuthField(
                        hintText: "Address",
                        icon: Icons.location_on,
                        controller: addressController,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Save & Continue Button
              AuthGradientButton(
                title: "Save & Continue",
                isLoading: _isLoading,
                onpressed: _saveMessDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
