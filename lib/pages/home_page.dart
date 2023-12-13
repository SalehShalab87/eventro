import 'package:eventro/components/event_tile.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:eventro/pages/event_details.dart';
import 'package:eventro/pages/event_page.dart';
import 'package:flutter/material.dart';
import 'package:eventro/components/drawer.dart';
import 'package:eventro/pages/NotificationPage.dart';
import 'package:eventro/pages/favorite_page.dart';
import 'package:eventro/pages/profile_page.dart';
import 'package:eventro/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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

  //add event to favorite
  void addEventToFavorite(Event event) {
    Provider.of<Booking>(context, listen: false).addEventToFavorites(event);

    //alert the user that the event go to the favoriet page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Successfully added!'),
        content: const Text('Check the favorite page'),
        actions: [
          MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
      builder: (context, value, child) => Scaffold(
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
            GestureDetector(
              onTap: () => goToNotificationPage(),
              child: const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(
                  Icons.notifications_active_outlined,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //search bar
              MySearchTextField(
                controller: searchController,
                hintText: 'Search',
              ),
              const SizedBox(
                height: 15,
              ),
              //upcoming events
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 50),
                      child: Text(
                        'Upcoming Events',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    GestureDetector(
                      child: const Text(
                        'See all',
                        style: TextStyle(
                            color: Color(0xffEC6408),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EventsPage()),
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
              const SizedBox(
                height: 10,
              ),
              // Horizontal list view for upcoming event
              SizedBox(
                height:
                    370, // Set a fixed height or use another appropriate value
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    //get event from event list to book
                    Event event = value.getUserEventToBook()[index];

                    //return the events to book
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EventDetails()),
                      ),
                      child: EventTile(
                        onTap: () => addEventToFavorite(event),
                        event: event,
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 100, left: 100, right: 100),
                child: Divider(
                  color: Colors.white,
                ),
              ),
              // hot picks
            ],
          ),
        ),
      ),
    );
  }
}
