// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import 'package:eventro/components/booked_events_tile.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> _events = []; // List to store fetched events

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            currentDay: DateTime.now(),
            daysOfWeekHeight: 20,
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.now(),
            lastDay: DateTime.utc(2026, 12, 31),
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine if this is the selected day
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` as well
              });
              // Fetch events for the selected day from Firestore
              _fetchEvents(selectedDay);
            },
            headerStyle: const HeaderStyle(
              headerMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              headerPadding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color.fromRGBO(236, 100, 8, 1),
              ),
              titleTextStyle: TextStyle(fontSize: 20),
              formatButtonVisible: false,
              titleCentered: true,
            ),
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
                outsideTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                weekendTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                todayDecoration: BoxDecoration(
                  color:
                      Color.fromRGBO(236, 100, 8, 90), // Color for today's date
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color:
                      Color.fromRGBO(236, 100, 8, 1), // Color for selected date
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(fontSize: 16, color: Colors.black)),
            daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black)),
          ),
          const SizedBox(
              height: 20), // Add some space between calendar and events
          Expanded(
            child: _events.isNotEmpty
                ? ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_events[index]);
                    },
                  )
                : _buildNoEventsPlaceholder(), // Show placeholder if no events
          ),
        ],
      ),
    );
  }

  // Function to fetch events from Firestore for a specific date
  void _fetchEvents(DateTime selectedDay) async {
    // Format selectedDay to match Firestore timestamp format
    Timestamp startTimestamp = Timestamp.fromDate(
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day));
    Timestamp endTimestamp = Timestamp.fromDate(
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day + 1));

    // Query Firestore collection for events within selected day
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('eventsCollection')
        .where('datetime', isGreaterThanOrEqualTo: startTimestamp)
        .where('datetime', isLessThan: endTimestamp)
        .get();

    // Process query results and store events in _events list
    List<Event> events =
        querySnapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    setState(() {
      _events = events;
    });
  }

  // Function to build UI for event card
  Widget _buildEventCard(Event event) {
    return BookedEventsTile(
      imageUrl: event.imageUrl,
      eventName: event.title,
      rating: event.rating,
      onDelete: () {
        deleteEvent(context, event.eventId);
      },
      eventID: event.eventId,
      icon: Icons.delete_outlined,
      currentAttendees: event.currentAttendees,
    );
  }

  // Function to build the placeholder widget when no events are available
  Widget _buildNoEventsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/favorite.png', // Path to your placeholder image
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 15),
          const Text(
            'No events available for selected date.',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Future<void> deleteEvent(BuildContext context, String eventId) async {
    try {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deleting'),
          content: const Text('Do you want to delete this event?'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
            const SizedBox(height: 10),
            MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
          ],
        ),
      );
      if (confirm != null && confirm) {
        // Delete the event from the events collection
        await FirebaseFirestore.instance
            .collection('eventsCollection')
            .doc(eventId)
            .delete();

        // Create a reference to the event document
        DocumentReference eventRef = FirebaseFirestore.instance
            .collection('eventsCollection')
            .doc(eventId);

        // Remove the event reference from users' collections
        QuerySnapshot<Map<String, dynamic>> usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();
        for (var userDoc in usersSnapshot.docs) {
          if (userDoc.data().containsKey('events')) {
            List<dynamic> eventsArray = userDoc['events'];
            if (eventsArray.contains(eventRef)) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userDoc.id)
                  .update({
                'events': FieldValue.arrayRemove([eventRef])
              });
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Event deleted successfully!'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ShowErrorMessage.showError(context, 'Unknown Error.... try again!');
      // Handle errors gracefully, such as showing an error message.
    }
  }
}
