import 'package:Tiffinity/data/constants.dart';
import 'package:Tiffinity/views/pages/customer_pages/customer_menu_page.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.ratings, //for mess information
    required this.distance,
    required this.isVeg,
    required this.messId,
  });

  final String title;
  final String description;
  final String ratings;
  final String distance;
  final bool isVeg;
  final String messId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.0), // Add vertical padding
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0), //card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style:
                          KTextStyle.titleTealText, //style from constants.dart
                    ),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        Text(' $distance km'),
                      ],
                    ), //distance
                  ],
                ),

                SizedBox(height: 9.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(
                          ' $ratings',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // Veg/Non-veg icon
                    if (isVeg) Symbols.vegSymbol else Symbols.nonVegSymbol,
                  ],
                ),

                SizedBox(height: 6.0),

                Text(
                  description,
                  style: KTextStyle.descriptionText, //style from constants.dart
                ),

                SizedBox(height: 10.0),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuPage(messId: messId),
                        ),
                      );
                    },
                    child: const Text(
                      'View Menu & details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
