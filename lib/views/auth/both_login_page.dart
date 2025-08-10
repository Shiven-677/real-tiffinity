import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/views/auth/both_signup_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_widget_tree.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_widget_tree.dart';
import 'package:Tiffinity/views/widgets/auth_field.dart';
import 'package:Tiffinity/views/widgets/auth_gradient_button.dart';

class BothLoginPage extends StatefulWidget {
  final String role;
  const BothLoginPage({super.key, required this.role});

  @override
  State<BothLoginPage> createState() => _BothLoginPageState();
}

class _BothLoginPageState extends State<BothLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!validateFields([emailController, passwordController])) {
      _showError("Please fill all the fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Get role from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!userDoc.exists) {
        _showError("User record not found");
        return;
      }

      String storedRole = userDoc['role'] ?? '';

      // Verify selected role matches stored role
      if (storedRole != widget.role) {
        _showError(
          "You are registered as a $storedRole. Please select $storedRole role to login.",
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  storedRole == 'customer'
                      ? const CustomerWidgetTree()
                      : const AdminWidgetTree(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  "Login.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                AuthField(
                  hintText: "Email",
                  icon: Icons.email,
                  controller: emailController,
                ),
                const SizedBox(height: 18),
                AuthField(
                  hintText: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 50),
                AuthGradientButton(
                  title: "Sign in",
                  onpressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 15),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context).textTheme.titleMedium,
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: const Color.fromARGB(255, 0, 117, 105),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            BothSignupPage(role: widget.role),
                                  ),
                                );
                              },
                      ),
                    ],
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

bool validateFields(List<TextEditingController> controllers) {
  for (final controller in controllers) {
    if (controller.text.trim().isEmpty) return false;
  }
  return true;
}
