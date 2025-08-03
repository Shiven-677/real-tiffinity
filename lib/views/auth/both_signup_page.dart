import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:practise/services/auth_services.dart';
import 'package:practise/views/auth/both_login_page.dart';
import 'package:practise/views/pages/admin_pages/admin_widget_tree.dart';
import 'package:practise/views/pages/customer_pages/customer_widget_tree.dart';
import 'package:practise/views/widgets/auth_field.dart';
import 'package:practise/views/widgets/auth_gradient_button.dart';

class BothSignupPage extends StatefulWidget {
  final String role;
  const BothSignupPage({super.key, required this.role});

  @override
  State<BothSignupPage> createState() => _BothSignupPageState();
}

class _BothSignupPageState extends State<BothSignupPage> {
  final AuthService _auth = AuthService();
  bool passwordsDoNotMatch = false;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() {
      passwordsDoNotMatch = false;
      _isLoading = true;
    });

    if (!validateFields([
      nameController,
      emailController,
      passwordController,
      confirmPasswordController,
      phoneNumController,
    ])) {
      setState(() => _isLoading = false);
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

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        passwordsDoNotMatch = true;
        _isLoading = false;
      });
      return;
    }

    try {
      await _auth.signUp(
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
              title: const Text("Sign Up Error"),
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
        child: KeyboardDismissOnTap(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Text(
                        "Sign Up.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildFormFields(),
                      const Spacer(),
                      AuthGradientButton(
                        title: "Sign Up",
                        onpressed: _handleSignUp,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                      _buildSignInLink(),
                      const Spacer(flex: 3),
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

  Widget _buildFormFields() {
    return Column(
      children: [
        AuthField(
          hintText: "Name",
          icon: Icons.person,
          controller: nameController,
        ),
        const SizedBox(height: 16),
        AuthField(
          hintText: "Phone no.",
          icon: Icons.phone,
          controller: phoneNumController,
        ),
        const SizedBox(height: 16),
        AuthField(
          hintText: "Email",
          icon: Icons.email,
          controller: emailController,
        ),
        const SizedBox(height: 16),
        AuthField(
          hintText: "Password",
          icon: Icons.lock,
          isPassword: true,
          controller: passwordController,
        ),
        const SizedBox(height: 16),
        AuthField(
          hintText: "Confirm Password",
          icon: Icons.lock,
          isPassword: true,
          controller: confirmPasswordController,
        ),
        if (passwordsDoNotMatch)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Passwords do not match",
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return RichText(
      text: TextSpan(
        text: "Already have an account? ",
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        children: [
          TextSpan(
            text: "Sign In",
            style: const TextStyle(
              color: Color(0xFF007569),
              fontWeight: FontWeight.bold,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BothLoginPage(role: widget.role),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;
  const KeyboardDismissOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}

bool validateFields(List<TextEditingController> controllers) {
  for (final controller in controllers) {
    if (controller.text.trim().isEmpty) return false;
  }
  return true;
}
