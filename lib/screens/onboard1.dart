import 'package:flutter/material.dart';

class Onboard1 extends StatelessWidget {
  const Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 27),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Image.asset('images/onboarding1.png', height: 300),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Plan Events Effortlessly',
              style: TextStyle(fontFamily: "Gilroy", fontSize: 28),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
                style: TextStyle(fontSize: 14, fontFamily: "Gilroy Pro"),
                textAlign: TextAlign.center,
                'Discover simplicity in planning your events.'),
          ],
        ),
      ),
    );
  }
}
