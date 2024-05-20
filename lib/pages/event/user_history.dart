// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/models/rating.dart';
import 'package:eventro/Services/rating_services.dart';
import 'package:eventro/pages/event/event_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyBookingHistory extends StatefulWidget {
  const MyBookingHistory({super.key});

  @override
  State<MyBookingHistory> createState() => _MyBookingHistoryState();
}

class _MyBookingHistoryState extends State<MyBookingHistory> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _bookingStream;
  SharedPreferences? prefs;
  final RatingService _ratingService = RatingService();
  bool hasAttened = false;

  @override
  void initState() {
    super.initState();
    _bookingStream = _getBookingStream();
    _initPrefs();
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {}); // Refresh the UI once prefs are loaded
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getBookingStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('dateOfBooked', descending: true)
        .snapshots();
  }

  Future<void> confirmAttendance(String bookingId) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Attendance'),
          content: const Text('Are you sure you want to confirm attendance?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffEC6408),
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffEC6408),
              ),
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'hasAtteended': true});
      if (mounted) {
        setState(() {
          hasAttened = true;
        });
      }
    }
  }

  Future<void> showRatingDialog(String eventId) async {
    double currentRating = 3.0; // Default or initial rating
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate the Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please leave a rating for this event:'),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: currentRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  currentRating = rating;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffEC6408)),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffEC6408)),
              child: const Text('Submit'),
              onPressed: () async {
                await _ratingService.submitEventRating(
                    Rating(eventId: eventId, rating: currentRating));
                await prefs?.setBool('hasRated$eventId', true);
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {}); // Refresh the UI
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking History'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _bookingStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xffEc6408),
            ));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/no_bookings.png', height: 300),
                  const SizedBox(height: 40),
                  const Text(
                    'You have no bookings yet!',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var event = doc.data() as Map<String, dynamic>;
              String ratingKey = 'hasRated${event['eventId']}';
              bool hasRated = prefs?.getBool(ratingKey) ?? false;
              final dateTime = (event['dateOfBooked'] as Timestamp).toDate();
              final formattedDate =
                  DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventDetails(eventId: event['eventId'])));
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(event['imageUrl']),
                      radius: 30,
                    ),
                    title: Text(event['title']),
                    subtitle: Text('Booked on: $formattedDate'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (event['hasAtteended'])
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 30,
                          ),
                        if (!event['hasAtteended'])
                          IconButton(
                            iconSize: 30,
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.red,
                            onPressed: () => confirmAttendance(doc.id),
                            tooltip: 'Confirm Attendance',
                          ),
                        if (event['hasAtteended'] && !hasRated)
                          IconButton(
                            iconSize: 30,
                            icon: const Icon(Icons.rate_review),
                            onPressed: () => showRatingDialog(event['eventId']),
                            tooltip: 'Rate Event',
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
