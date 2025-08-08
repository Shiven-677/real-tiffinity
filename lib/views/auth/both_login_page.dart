import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:practise/services/auth_services.dart';
import 'package:practise/views/auth/both_signup_page.dart';
import 'package:practise/views/pages/admin_pages/admin_widget_tree.dart';
import 'package:practise/views/pages/customer_pages/customer_widget_tree.dart';
import 'package:practise/views/widgets/auth_field.dart';
import 'package:practise/views/widgets/auth_gradient_button.dart';

class BothLoginPage extends StatefulWidget {
  final String role;
  const BothLoginPage({super.key, required this.role});

  @override
  State<BothLoginPage> createState() => _BothLoginPageState();
}

class _BothLoginPageState extends State<BothLoginPage> {
  final AuthService _auth = AuthService();
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
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Validation Error"),
              content: const Text("Please fill all the fields"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  widget.role == 'customer'
                      ? const CustomerWidgetTree()
                      : const AdminWidgetTree(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Login Failed"),
              content: Text(e.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50), // space for skip button
                  Text(
                    "Login.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
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

            // Skip button at top right
            Positioned(
              top: 10,
              right: 10,
              child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              widget.role == 'customer'
                                  ? const CustomerWidgetTree()
                                  : const AdminWidgetTree(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
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
