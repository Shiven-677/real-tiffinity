import 'package:flutter/material.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_home_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_profile_page.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_settings_page.dart';
import 'package:Tiffinity/views/widgets/admin_navbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Tiffinity/views/pages/admin_pages/menu_management_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWidgetTree extends StatelessWidget {
  const AdminWidgetTree({super.key});

  Future<void> _toggleOnlineStatus(String uid, bool status) async {
    await FirebaseFirestore.instance.collection('messes').doc(uid).update({
      'isOnline': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

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
          // 🔹 Online/Offline toggle
          StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('messes')
                    .doc(uid)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              bool isOnline = snapshot.data?['isOnline'] ?? false;
              return Switch(
                value: isOnline,
                onChanged: (value) => _toggleOnlineStatus(uid, value),
                activeColor: Colors.green,
              );
            },
          ),

          // 🔹 Theme toggle
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

          // 🔹 Settings button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CustomerSettingsPage(title: 'Settings');
                  },
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: adminSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),

      bottomNavigationBar: AdminNavbarWidget(),
    );
  }
}
