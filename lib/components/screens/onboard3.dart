import 'package:flutter/material.dart';

class Onboard3 extends StatelessWidget {
  const Onboard3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:27),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Image.asset(
              'images/onboarding3.png',
              height: 300,
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Discover Local Eevents',
              style: TextStyle(fontFamily: "Gilroy", fontSize: 28),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
                style: TextStyle(fontFamily: "Gilroy Pro", fontSize: 14),
                textAlign: TextAlign.center,
                'Explore local happenings easily and handy.'),
          ],
        ),
      ),
    );
  }
}
