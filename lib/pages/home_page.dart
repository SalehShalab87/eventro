import 'package:eventro/components/drawer.dart';
import 'package:eventro/pages/favorite_page.dart';
import 'package:eventro/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:eventro/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // navigate to the user profile
  void goToUserProfile() {
    //pop the drawer
    Navigator.pop(context);
    //go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  //navigate to the favorite page
  void goToFavoritePage() {
    //pop the drawer
    Navigator.pop(context);
    //go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritePage()),
    );
  }

  // Dummy data for events (replace this with your actual data)
  List<String> events = ['Event 1', 'Event 2', 'Event 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfileTap: goToUserProfile,
        onSignOutTap: () => _signOut(context),
        onFavoriteTap: goToFavoritePage,
      ),
      appBar: AppBar(
        actions: [
          if (_user != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Hi, ${_user!.displayName ?? ''}',
                style: const TextStyle(fontFamily: 'Gilroy', fontSize: 18),
              ),
            ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(events[index]),
                // Add more details or buttons as needed
              ),
            );
          },
        ),
      ),
    );
  }
}
