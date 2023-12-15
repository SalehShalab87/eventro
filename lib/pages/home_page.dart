import 'package:eventro/components/event_list_builder.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/pages/event/create_event_page.dart';
import 'package:eventro/pages/event/event_page.dart';
import 'package:flutter/material.dart';
import 'package:eventro/components/drawer.dart';
import 'package:eventro/pages/NotificationPage.dart';
import 'package:eventro/pages/event/favorite_page.dart';
import 'package:eventro/pages/profile_page.dart';
import 'package:eventro/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller for search text field
  final searchController = TextEditingController();
  // User object to store the current user
  late User? _user;

  @override
  void initState() {
    super.initState();
    // Fetch the current user when the widget is initialized
    _user = FirebaseAuth.instance.currentUser;
  }

  // Method to sign out the user
  void _signOut(BuildContext context) {
    signOutFromFirebase(context);
  }

  // Method to navigate to the user profile page
  void _goToUserProfile() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  // Method to navigate to the favorite page
  void _goToFavoritePage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to favorite page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritePage()),
    );
  }

  // Method to navigate to the notification page
  void _goToNotificationPage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to notification page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  }

  // Method to navigate to the events page
  void _goToEventsPage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to notification page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventsPage()),
    );
  }

  // Method to handle the "Create Event" button press
  void _onCreateEventPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventPage()),
    );
  }

  // Method to build the actions for the AppBar
  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[];
    // Display user greeting if user is logged in
    if (_user != null) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            'Hi, ${_user!.displayName ?? ''}',
            style: const TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    // Notification icon
    actions.add(
      GestureDetector(
        onTap: _goToNotificationPage,
        child: const Padding(
          padding: EdgeInsets.only(right: 15),
          child: Icon(
            Icons.notifications_active_outlined,
          ),
        ),
      ),
    );
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
      builder: (context, value, child) => Scaffold(
        // Floating action button for creating events
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xffEC6408),
          onPressed: _onCreateEventPressed,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        // Drawer for navigation options
        drawer: MyDrawer(
          onProfileTap: _goToUserProfile,
          onFavoriteTap: _goToFavoritePage,
          onEventsTap: _goToEventsPage,
          onSignOutTap: () => _signOut(context),
        ),
        // AppBar at the top of the screen
        appBar: AppBar(
          elevation: 0.0,
          // Actions on the right side of the AppBar
          actions: _buildAppBarActions(),
        ),
        // Body of the screen, scrollable column
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Search bar
              MySearchTextField(
                controller: searchController,
                hintText: 'Search',
              ),
              const SizedBox(height: 15),
              // Upcoming events section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 75),
                      child: Text(
                        'Events For You',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    GestureDetector(
                      onTap: _goToEventsPage,
                      child: const Text(
                        'See all',
                        style: TextStyle(
                            color: Color(0xffEC6408),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Color(0xffEC4608),
                      size: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Horizontal list view for upcoming events
              const SizedBox(
                height: 360,
                child: EventListBuilder(),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 100, left: 100, right: 100),
                child: Divider(color: Colors.white),
              ),
              // Hot picks or additional sections can be added here
            ],
          ),
        ),
      ),
    );
  }
}
