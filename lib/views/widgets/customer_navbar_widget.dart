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
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ], //total 2 items
          onDestinationSelected: (int value) {
            customerSelectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
