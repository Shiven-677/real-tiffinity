import 'package:Tiffinity/views/auth/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Tiffinity/services/image_service.dart';
import 'dart:io';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State {
  late TextEditingController messNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    messNameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    descriptionController = TextEditingController();
    _loadMessData();
  }

  Future<void> _loadMessData() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      final doc =
          await FirebaseFirestore.instance
              .collection('messes')
              .doc(userId)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          messNameController.text = data['messName'] ?? '';
          phoneController.text = data['phone'] ?? '';
          addressController.text = data['address'] ?? '';
          descriptionController.text = data['description'] ?? '';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Photo'),
          content: const Text('Choose where to upload photo from:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );
  }

  Future _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      final fileSizeMB = fileSize / 1024 / 1024;
      if (fileSize > 32 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Image too large: ${fileSizeMB.toStringAsFixed(2)}MB\nMax: 32MB allowed',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      setState(() => _selectedImage = file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Image selected: ${fileSizeMB.toStringAsFixed(2)}MB',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      final fileSizeMB = fileSize / 1024 / 1024;
      if (fileSize > 32 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Image too large: ${fileSizeMB.toStringAsFixed(2)}MB\nMax: 32MB allowed',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      setState(() => _selectedImage = file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Image selected: ${fileSizeMB.toStringAsFixed(2)}MB',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      Map<String, dynamic> updateData = {
        'messName': messNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'description': descriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_selectedImage != null) {
        print('🖼️ Uploading profile image...');
        final imageUrl = await ImageService.uploadToImgBB(_selectedImage!);

        if (imageUrl == 'SIZE_EXCEEDED') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Image too large! Maximum 32MB allowed.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          setState(() => _isSaving = false);
          return;
        }

        if (imageUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Image upload failed. Check internet.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isSaving = false);
          return;
        }

        updateData['messImage'] = imageUrl;
        _selectedImage = null;
      }

      await FirebaseFirestore.instance
          .collection('messes')
          .doc(userId)
          .update(updateData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully ✅'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Close the dialog first
                  Navigator.of(context).pop();

                  // Show loading indicator
                  if (mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => AlertDialog(
                            content: Row(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(width: 16),
                                Text(
                                  'Logging out...',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                    );
                  }

                  // Sign out from Firebase
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  // Close loading dialog
                  Navigator.of(context).pop();

                  // Navigate to WelcomePage with clear navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                    (Route route) => false,
                  );
                } catch (e) {
                  if (mounted) {
                    // Close loading dialog if shown
                    try {
                      Navigator.of(context).pop();
                    } catch (_) {}

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Logout failed: $e')),
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
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scrollable "Mess Info" Header with teal background and white text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color.fromARGB(255, 27, 84, 78),
              child: const Text(
                'Mess Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Scrollable Content with Profile Image and Form
            Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('messes')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messData = snapshot.data!.data() as Map?;
                  final currentImage = messData?['messImage'] as String?;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image Section (Scrollable)
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 27, 84, 78),
                                  width: 3,
                                ),
                                image:
                                    _selectedImage != null
                                        ? DecorationImage(
                                          image: FileImage(_selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                        : currentImage != null
                                        ? DecorationImage(
                                          image: NetworkImage(currentImage),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  _selectedImage == null && currentImage == null
                                      ? const Icon(
                                        Icons.restaurant,
                                        size: 60,
                                        color: Color.fromARGB(255, 27, 84, 78),
                                      )
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Change Photo'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Form Fields
                      // Mess Name
                      TextField(
                        controller: messNameController,
                        decoration: InputDecoration(
                          labelText: 'Mess Name',
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Address
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              27,
                              84,
                              78,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // LOGOUT BUTTON WITH RED ICON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
