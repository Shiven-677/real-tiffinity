import 'package:flutter/material.dart';
import 'package:Tiffinity/data/notifiers.dart';

class AdminNavbarWidget extends StatelessWidget {
  const AdminNavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: adminSelectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.menu_book), label: 'Menu'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ], //total 2 items
          onDestinationSelected: (int value) {
            adminSelectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
