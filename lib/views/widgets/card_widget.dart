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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Card(
          color: isDark ? Colors.grey[850] : Colors.white, // ✅ Dark mode card
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 27, 84, 78),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color:
                              isDark ? Colors.grey[300] : Colors.grey[700], // ✅
                        ),
                        Text(
                          ' $distance km',
                          style: TextStyle(
                            color:
                                isDark ? Colors.grey[300] : Colors.black87, // ✅
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 9.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(
                          ' $ratings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black, // ✅
                          ),
                        ),
                      ],
                    ),
                    if (isVeg) Symbols.vegSymbol else Symbols.nonVegSymbol,
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600], // ✅
                  ),
                ),
                const SizedBox(height: 10.0),
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
