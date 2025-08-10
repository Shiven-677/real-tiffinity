import 'package:flutter/material.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_home_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_menu_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_profile_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_settings_page.dart';
import 'package:Tiffinity/views/widgets/admin_navbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tiffinity/views/pages/admin_pages/menu_management_page.dart';


class AdminWidgetTree extends StatelessWidget {
  const AdminWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminHomePage(),
      MenuManagementPage(),
      AdminProfilePage(),
    ];
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: Text("Admin", style: TextStyle(fontSize: 29)), //title

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () async {
              isDarkModeNotifier.value =
                  !isDarkModeNotifier.value; //toggle dark mode
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setBool(
                KConstants.themeModeKey,
                isDarkModeNotifier.value,
              );
            }, //action button
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
                    return CustomerSettingsPage(
                      title: 'Settingsss',
                    ); //navigate to settings page
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: adminSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),

      //bottom navigation bar
      bottomNavigationBar: AdminNavbarWidget(),
    );
  }
}
