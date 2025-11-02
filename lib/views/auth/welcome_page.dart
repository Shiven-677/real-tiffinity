import 'package:flutter/material.dart';
import 'package:Tiffinity/views/auth/onboarding.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Static background image (ensure filename case matches your asset)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/First_Page.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Teal overlay for readability
          Container(color: const Color(0x6617A2A0)),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  FittedBox(
                    child: Text(
                      "Tiffinity",
                      style:
                          theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 12,
                            color: Colors.white,
                          ) ??
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 54,
                            letterSpacing: 12,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // This button navigates to OnboardingPage
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingPage(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0E8A87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Get Started"),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
