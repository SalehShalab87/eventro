// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/Services/auth/sign_out.dart';
import 'package:eventro/components/event_list_builder.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/pages/event/create_event_page.dart';
import 'package:eventro/pages/event/events_page.dart';
import 'package:eventro/pages/event/user_events.dart';
import 'package:eventro/pages/event/user_history.dart';
import 'package:flutter/material.dart';
import 'package:eventro/components/drawer.dart';
import 'package:eventro/pages/NotificationPage.dart';
import 'package:eventro/pages/event/favorite_page.dart';
import 'package:eventro/pages/profile/profile_page.dart';
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
  String searchQuery = '';
  String? eventTypeFilter;
  // User object to store the current user
  late User? _user;
  Stream<int>? notificationCount;

  @override
  void initState() {
    super.initState();
    // Fetch the current user when the widget is initialized
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      notificationCount = getNotificationCount(_user!.uid);
    }
  }

  // Method to sign out the user
  void _signOut(BuildContext context) {
    signOutFromFirebase(context);
  }

  Stream<int> getNotificationCount(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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

  void _goToMyBookingsPage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyBookingHistory()),
    );
  }

  void _goToMyEventsPage() {
    // Pop the drawer
    Navigator.pop(context);
    // Go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyEvents()),
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
    if (_user != null) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            'Hi, ${_user!.displayName ?? ''}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    actions.add(
      Stack(
        alignment: Alignment.topRight,
        children: [
          IconButton(
            iconSize: 25,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _goToNotificationPage,
          ),
          StreamBuilder<int>(
            stream: notificationCount,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data! > 0) {
                return Positioned(
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              } else {
                return Container(); // No notifications, don't display the counter
              }
            },
          ),
        ],
      ),
    );

    return actions;
  }

  List<Map<String, dynamic>> eventTypes = [
    {'name': 'Festival', 'icon': Icons.festival},
    {'name': 'Music Event', 'icon': Icons.music_note},
    {'name': 'Sports Event', 'icon': Icons.sports_soccer},
    {'name': 'Coffee House Meetup', 'icon': Icons.local_cafe},
    {'name': 'Charity Event', 'icon': Icons.volunteer_activism},
    {'name': 'Cycles Event', 'icon': Icons.directions_bike},
    {'name': 'Birthday Party', 'icon': Icons.cake},
    {'name': 'Wedding', 'icon': Icons.wc},
    {'name': 'Art Exhibition', 'icon': Icons.brush},
    {'name': 'Theater Play', 'icon': Icons.theater_comedy},
    {'name': 'Movie Night', 'icon': Icons.movie},
  ];

  Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedType = eventTypeFilter;

    final String? pickedType = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Event Type'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: eventTypes.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile<String>(
                  activeColor: const Color(0xffEC6408),
                  title: Text(eventTypes[index]['name']),
                  secondary: Icon(eventTypes[index]['icon']),
                  value: eventTypes[index]['name'],
                  groupValue: selectedType,
                  onChanged: (String? value) {
                    Navigator.pop(context, value);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (pickedType != null) {
      setState(() {
        eventTypeFilter = pickedType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
      builder: (context, value, child) => Scaffold(
        // Floating action button for creating events
        floatingActionButton: FloatingActionButton(
          elevation: 4.0,
          backgroundColor: const Color(0xffEC6408),
          onPressed: _onCreateEventPressed,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        // Drawer for navigation options
        drawer: MyDrawer(
          onHistoryEventsTap: _goToMyBookingsPage,
          onMyEventsTap: _goToMyEventsPage,
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
        body: GestureDetector(
          onTap: () {
            // Remove focus from text fields when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search bar
                MySearchTextField(
                  controller: searchController,
                  hintText: 'Search',
                  onChanged: (value) {
                    if (value.isEmpty && eventTypeFilter != null) {
                      // If search is cleared and a filter is active, apply the filter
                      setState(() {});
                    } else {
                      setState(() {
                        searchQuery = value;
                        eventTypeFilter = null; // Clear filter when searching
                      });
                    }
                  },
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Upcoming events section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 80),
                        child: Text(
                          'Discover Events',
                          style: TextStyle(fontSize: 22),
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
                SizedBox(
                  height: 360,
                  child: EventListBuilder(
                      searchQuery: searchQuery,
                      eventTypeFilter: eventTypeFilter),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 40, left: 25, right: 25),
                ),
                const SizedBox(height: 50),
                // Hot picks or additional sections can be added here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
