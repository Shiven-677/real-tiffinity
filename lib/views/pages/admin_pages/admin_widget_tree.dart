import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/data/notifiers.dart';
import 'package:Tiffinity/views/auth/both_login_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_home_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/menu_management_page.dart';
import 'package:Tiffinity/views/pages/admin_pages/admin_profile_page.dart';
import 'package:Tiffinity/views/widgets/admin_navbar_widget.dart';

class AdminWidgetTree extends StatelessWidget {
  const AdminWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final List pages = [
      const AdminHomePage(),
      const MenuManagementPage(),
      const AdminProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('messes')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final messName = snapshot.data!.get('messName') ?? 'Mess';
              return Text(
                messName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return const Text(
              'Tiffinity',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            );
          },
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: adminSelectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: const AdminNavbarWidget(),
    );
  }
}
