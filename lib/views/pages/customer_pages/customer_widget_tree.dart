import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Tiffinity/views/auth/both_login_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_home_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_orders_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_profile_page.dart';
import 'package:Tiffinity/views/widgets/customer_navbar_widget.dart';
import 'package:Tiffinity/data/notifiers.dart';

class CustomerWidgetTree extends StatelessWidget {
  const CustomerWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const CustomerHomePage(),
      const CustomerOrdersPage(),
      const CustomerProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tiffinity',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Login button for guest users
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: 'Login',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BothLoginPage(role: 'customer'),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // ❌ REMOVED THEME TOGGLE FROM HERE
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: customerSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: const CustomerNavbarWidget(),
    );
  }
}
