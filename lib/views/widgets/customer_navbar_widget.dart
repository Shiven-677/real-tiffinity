import 'package:Tiffinity/data/notifiers.dart';
import 'package:flutter/material.dart';

class CustomerNavbarWidget extends StatelessWidget {
  const CustomerNavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: customerSelectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ], // Now 3 items
          onDestinationSelected: (int value) {
            customerSelectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
