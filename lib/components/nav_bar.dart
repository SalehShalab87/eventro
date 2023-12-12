import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavBar extends StatelessWidget {
  const MyNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const GNav(
        tabs: [
          GButton(
            icon: Icons.home_outlined,
            text: 'HOME',
          ),
          GButton(
            icon: Icons.calendar_month_outlined,
            text: 'EVENTS',
          ),
        ],
      ),
    );
  }
}
