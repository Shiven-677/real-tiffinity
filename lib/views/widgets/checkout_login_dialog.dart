import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/services/auth_services.dart';

class CheckoutLoginDialog extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const CheckoutLoginDialog({super.key, required this.onLoginSuccess});

  @override
  State<CheckoutLoginDialog> createState() => _CheckoutLoginDialogState();
}

class _CheckoutLoginDialogState extends State<CheckoutLoginDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;

      if (_isSignUp) {
        // Sign Up
        userCredential = await _authService.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // Sign In
        userCredential = await _authService.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      await _handleLogin(userCredential);
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.message);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  Future<void> _handleLogin(UserCredential userCredential) async {
    final uid = userCredential.user!.uid;
    final email = userCredential.user!.email!;

    // Check if user exists
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists || _isSignUp) {
      // Create or update user profile
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (!mounted) return;
    Navigator.pop(context);
    widget.onLoginSuccess();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isSignUp ? 'Create Account' : 'Login to Continue',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                _isSignUp
                    ? 'Sign up to place your order'
                    : 'Please login to complete checkout',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Email field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login/Signup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            _isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle between login and signup
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text:
                            _isSignUp
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                      ),
                      TextSpan(
                        text: _isSignUp ? 'Login' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
