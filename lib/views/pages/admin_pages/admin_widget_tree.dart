import 'package:flutter/material.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_home_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_profile_page.dart';
import 'package:Tiffinity/views/widgets/admin_navbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tiffinity/views/pages/admin_pages/menu_management_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Tiffinity/services/notification_service.dart';

class AdminWidgetTree extends StatefulWidget {
  const AdminWidgetTree({super.key});

  @override
  State<AdminWidgetTree> createState() => _AdminWidgetTreeState();
}

class _AdminWidgetTreeState extends State<AdminWidgetTree> {
  @override
  void initState() {
    super.initState();
    NotificationService().saveTokenToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminHomePage(),
      MenuManagementPage(),
      AdminProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin", style: TextStyle(fontSize: 29)),
        centerTitle: true,
        actions: [
          // Theme toggle only
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
        valueListenable: adminSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: AdminNavbarWidget(),
    );
  }
}
