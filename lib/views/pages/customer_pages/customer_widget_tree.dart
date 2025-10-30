import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/views/auth/both_login_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_home_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_orders_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_profile_page.dart';
import 'package:Tiffinity/views/widgets/customer_navbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          // Theme toggle
          IconButton(
            onPressed: () async {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool(
                KConstants.themeModeKey,
                isDarkModeNotifier.value,
              );
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode);
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: customerSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: const CustomerNavbarWidget(),
    );
  }
}
