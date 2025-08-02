import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:practise/views/auth/onboarding.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lotties/home.json"),
            FittedBox(
              child: Text(
                "Tiffinity",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 70.0,
                  letterSpacing: 40.0, //design
                ),
              ),
            ), // Add some space between text and button
            SizedBox(height: 20.0),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OnboardingPage();
                    },
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 40.0), //full width button
              ),
              child: Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}
