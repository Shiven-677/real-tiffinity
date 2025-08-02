import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:practise/data/constants.dart';
import 'package:practise/views/auth/role_selection_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lotties/cooking.json'),
                SizedBox(height: 20), // Add space between hero and text field

                SizedBox(height: 20), // space

                Text(
                  "Tiffiinity is the way to order your healthy meals!!",
                  style: KTextStyle.titleTealText,
                  textAlign: TextAlign.justify,
                ),

                SizedBox(height: 20), // space

                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RoleSelectionPage(); //navigate to settings page
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      40.0,
                    ), //full width button
                  ),
                  child: Text('Next'),
                ),

                SizedBox(height: 70), // last space
              ],
            ),
          ),
        ),
      ),
    );
  }
}
