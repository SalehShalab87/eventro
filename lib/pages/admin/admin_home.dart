// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/booked_events_tile.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:eventro/models/event.dart';
import 'package:eventro/pages/admin/PendingEventsPage.dart';
import 'package:eventro/pages/admin/components/count_card.dart';
import 'package:eventro/pages/event/event_details.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Stream<int> userCountStream;
  late Stream<int> eventCountStream;
  late Stream<int> pendingEventCountStream;
  late Stream<int> approvedEventStream;
  late Stream<List<Event>> topEventStream;

  @override
  void initState() {
    super.initState();
    userCountStream = _getUserCountStream();
    eventCountStream = _getEventCountStream();
    pendingEventCountStream = _getPendingEventCountStream();
    approvedEventStream = _getApprovedEventCountStream();
    topEventStream = _getTopEvent();
  }

  Stream<List<Event>> _getTopEvent() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .orderBy('currentAttendees', descending: true)
        .limit(3)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList());
  }

  Stream<int> _getUserCountStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _getEventCountStream() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _getPendingEventCountStream() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _getApprovedEventCountStream() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Future<void> deleteEvent(BuildContext context, String eventId) async {
    try {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deleting'),
          content: const Text('Do you want to delet this event?'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
            const SizedBox(height: 10),
            MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
          ],
        ),
      );
      if (confirm != null && confirm) {
        await FirebaseFirestore.instance
            .collection('eventsCollection')
            .doc(eventId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Event deleted successfully!...'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ShowErrorMessage.showError(context, 'Unknown Error.... try again!');
      // Handle errors gracefully, such as showing an error message.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StreamBuilder<int>(
                  stream: userCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffEC6408),
                        ),
                      );
                    }
                    return AdminCountCard(
                      count: snapshot.data ?? 0,
                      title: 'Users',
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: eventCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffEC6408),
                        ),
                      );
                    }
                    return AdminCountCard(
                      count: snapshot.data ?? 0,
                      title: 'Events',
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: pendingEventCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffEC6408),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PendingEventsPage())),
                      child: AdminCountCard(
                        count: snapshot.data ?? 0,
                        title: 'Pending Events',
                      ),
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: approvedEventStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xffEC6408),
                      );
                    }
                    return AdminCountCard(
                      count: snapshot.data ?? 0,
                      title: 'Approved Events',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Top Events',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            StreamBuilder<List<Event>>(
              stream: topEventStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xffEC6408)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No top events available.');
                }
                return Column(
                  children: snapshot.data!.map((event) {
                    return BookedEventsTile(
                      imageUrl: event.imageUrl,
                      eventName: event.title,
                      currentAttendees: event.currentAttendees,
                      onDelete: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetails(eventId: event.eventId),
                          ),
                        );
                      },
                      eventID: event.eventId,
                      icon: Icons.info_outline,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
