import 'package:flutter/material.dart';

class Onboard2 extends StatelessWidget {
  const Onboard2({super.key});

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
              'images/onboarding2.png',
              height: 300,
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Book and Enjoy Events',
              style: TextStyle(fontFamily: "Gilroy", fontSize: 28),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              textAlign: TextAlign.center,
              'Browse, book, and cherish events effortlessly.',
              style: TextStyle(fontSize: 14, fontFamily: "Gilroy Pro"),
            )
          ],
        ),
      ),
    );
  }
}
