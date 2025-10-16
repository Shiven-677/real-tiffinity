import 'package:flutter/material.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
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
      CustomerHomePage(),
      CustomerOrdersPage(),
      CustomerProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tiffinity",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Only theme toggle button
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
            icon: ValueListenableBuilder<bool>(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode);
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: customerSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: CustomerNavbarWidget(),
    );
  }
}
