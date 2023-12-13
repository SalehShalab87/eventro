import 'package:eventro/components/event_deatails.dart';
import 'package:eventro/components/event_tile.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/pages/event_page.dart';
import 'package:flutter/material.dart';
import 'package:eventro/components/drawer.dart';
import 'package:eventro/pages/NotificationPage.dart';
import 'package:eventro/pages/favorite_page.dart';
import 'package:eventro/pages/profile_page.dart';
import 'package:eventro/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // search text controller
  final searchController = TextEditingController();
  late User? _user; // User object to store the current user

  @override
  void initState() {
    super.initState();
    // Fetch the current user when the widget is initialized
    _user = FirebaseAuth.instance.currentUser;
  }

  // Sign User Out Method
  void _signOut(BuildContext context) {
    signOutFromFirebase(context);
  }

  // Navigate to the user profile
  void goToUserProfile() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  // Navigate to the favorite page
  void goToFavoritePage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to favorite page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritePage()),
    );
  }

  // Navigate to the notification page
  void goToNotificationPage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to notification page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  }

  //navigate to the events Page
  goToEventsPage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to notification page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfileTap: goToUserProfile,
        onFavoriteTap: goToFavoritePage,
        onEventsTap: goToEventsPage,
        onSignOutTap: () => _signOut(context),
      ),
      appBar: AppBar(
        elevation: 0.0,
        actions: [
          if (_user != null)
            Text(
              'Hi, ${_user!.displayName ?? ''}',
              style: const TextStyle(fontFamily: 'Gilroy', fontSize: 18),
            ),
          IconButton(
            onPressed: goToNotificationPage,
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          //search bar
          MySearchTextField(controller: searchController, hintText: 'Search'),

          const SizedBox(
            height: 15,
          ),

          //upcoming events
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 24),
                ),
                Text(
                  'See all',
                  style: TextStyle(
                      color: Color(0xffEC6408), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    Event event = Event(
                        'Event 1', 'images/slogo.png', 'cool event',
                        price: 'Free');
                    return EventTile(
                      event: event,
                    );
                  }))
          // hot picks
        ],
      ),
    );
  }
}
