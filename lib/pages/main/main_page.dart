// ignore_for_file: file_names
import 'package:eventro/pages/event/events_page.dart';
import 'package:eventro/pages/event/favorite_page.dart';
import 'package:eventro/pages/main/home_page.dart';
import 'package:eventro/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

// page index
int _currnetindex = 0;

//list for the nav bar
List<Widget> _pages = <Widget>[
  //home Page
  const HomePage(),
  //favorite Page
  const FavoritePage(),
  //events Page
  const EventsPage(),
  //profile Page
  const ProfilePage(),
];

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages.elementAt(_currnetindex)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: GNav(
          tabBackgroundColor: const Color(0xffEC6408),
          padding: const EdgeInsets.all(16),
          gap: 8,
          selectedIndex: _currnetindex,
          onTabChange: (index) {
            setState(() {
              _currnetindex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Home',
            ),
            GButton(
              icon: Icons.favorite_outline_outlined,
              text: 'Favor',
            ),
            GButton(
              icon: Icons.event_outlined,
              text: 'Events',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Profile',
            )
          ],
        ),
      ),
    );
  }
}
