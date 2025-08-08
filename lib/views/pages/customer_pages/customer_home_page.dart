import 'package:flutter/material.dart';
import 'package:Tiffinity/views/widgets/card_widget.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Search for mess or tiffin services',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 8.0),
            CardWidget(
              title: 'Zoey kitchen',
              description:
                  'Specialized in south Indian cuisine, offering a variety of tiffin services.',
              ratings: '4.5',
              distance: '0.5',
              isVeg: true, //for mess information
            ),

            CardWidget(
              title: 'Krault Kitchen',
              description: 'Specialized in gavti food and chana.',
              ratings: '4.5',
              distance: 'very far',
              isVeg: true, //for mess information
            ),

            CardWidget(
              title: 'Homey Meals',
              description: 'Specialty in north Indian food.',
              ratings: '4.2',
              distance: '0.8',
              isVeg: false, //for mess information
            ),

            CardWidget(
              title: 'Annapurna Tiffins',
              description: 'Specialized in authentic maharashtrian cuisine.',
              ratings: '3.9',
              distance: '1.2', //for mess information
              isVeg: true,
            ),

            CardWidget(
              title: 'rohit gay',
              description: 'Suitable for bulk orders and meal prep.',
              ratings: '4.8',
              distance: '0.2', //for mess information
              isVeg: true,
            ),

            CardWidget(
              title: 'Tripura Mess',
              description: 'Known for its traditional Bengali dishes.',
              ratings: '4.5',
              distance: '1.6', //for mess information
              isVeg: false,
            ),
          ],
        ),
      ),
    );
  }
}
