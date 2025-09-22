import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_home_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_profile_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_settings_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_orders_page.dart'; // NEW IMPORT
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/customer_navbar_widget.dart';

class CustomerWidgetTree extends StatelessWidget {
  const CustomerWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CustomerHomePage(),
      CustomerOrdersPage(), // NEW PAGE
      CustomerProfilePage(),
    ];

    return Scaffold(
      // Rest of your existing code stays the same...
      appBar: AppBar(
        title: Text("Tiffinity", style: TextStyle(fontSize: 29)),
        centerTitle: true,
        actions: [
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CustomerSettingsPage(title: 'Settingsss');
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: customerSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: CustomerNavbarWidget(),
    );
  }
}
