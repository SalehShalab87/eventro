// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/booked_events_tile.dart';
import 'package:flutter/material.dart';
import 'package:eventro/components/created_event_tile.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:eventro/models/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyEvents extends StatelessWidget {
  const MyEvents({super.key});

  // Function to delete an event document from Firestore
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
        final String userId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('eventsCollection')
            .doc(eventId)
            .delete();
        // Create a reference to the event document
        DocumentReference eventRef = FirebaseFirestore.instance
            .collection('eventsCollection')
            .doc(eventId);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'events': FieldValue.arrayRemove([eventRef]),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Event deleted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ShowErrorMessage.showError(context, 'Unknown Error.... try again!');
      // Handle errors gracefully, such as showing an error message.
    }
  }

  Future<void> deletBookedEvent(BuildContext context, String eventId) async {
    try {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Canceling'),
          content:
              const Text('Do you want to cancel the booking for this event?'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
            const SizedBox(height: 10),
            MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
          ],
        ),
      );
      if (confirm != null && confirm) {
        bool success = await Booking().cancelBooking(context, eventId);
        if (success) {
          // If cancellation is successful, show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Booking cancelled successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ShowErrorMessage.showError(context, 'Unknown Error.... try again!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId =
        FirebaseAuth.instance.currentUser!.uid; // Your user ID here

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                'Created Events',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Builder(builder: (context) {
              return Flexible(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffEC6408),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final Map<String, dynamic>? userData =
                            snapshot.data!.data() as Map<String, dynamic>?;

                        if (userData != null &&
                            userData.containsKey('events')) {
                          List<DocumentReference> eventRefs =
                              List<DocumentReference>.from(userData['events']);

                          if (eventRefs.isNotEmpty) {
                            return ListView.builder(
                              itemCount: eventRefs.length,
                              itemBuilder: (context, index) {
                                return StreamBuilder<DocumentSnapshot>(
                                  stream: eventRefs[index].snapshots(),
                                  builder: (context, eventSnapshot) {
                                    if (!eventSnapshot.hasData ||
                                        eventSnapshot.data == null ||
                                        eventSnapshot.data!.data() == null) {
                                      return const SizedBox(); // Return an empty container
                                    }
                                    final eventData = eventSnapshot.data!.data()
                                        as Map<String, dynamic>;

                                    return CreatedEventTile(
                                      icon: Icons.delete_outline,
                                      imageUrl: eventData['imageUrl'] ?? '',
                                      eventName: eventData['title'] ?? '',
                                      status: eventData['status'] ?? '',
                                      onDelete: () {
                                        deleteEvent(
                                            context, eventSnapshot.data!.id);
                                      },
                                      eventID: eventSnapshot.data!.id,
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('No Created Events available'),
                            );
                          }
                        } else {
                          return const Center(
                            child: Text('No Created Events available'),
                          );
                        }
                      } else {
                        return const Text('No data available');
                      }
                    }
                  },
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                'Booked Events',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Builder(builder: (context) {
              return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Color(0xffEC6408),
                      ));
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.hasData) {
                        final List<DocumentSnapshot> bookingDocs =
                            snapshot.data!.docs;

                        if (bookingDocs.isNotEmpty) {
                          return ListView.builder(
                            itemCount: bookingDocs.length,
                            itemBuilder: (context, index) {
                              final String eventId =
                                  bookingDocs[index]['eventId'];
                              return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('eventsCollection')
                                    .doc(eventId)
                                    .snapshots(),
                                builder: (context, eventSnapshot) {
                                  if (!eventSnapshot.hasData ||
                                      eventSnapshot.data == null ||
                                      eventSnapshot.data!.data() == null) {
                                    return const SizedBox(); // Return an empty container
                                  }
                                  final eventData = eventSnapshot.data!.data()
                                      as Map<String, dynamic>;
                                  return BookedEventsTile(
                                    icon: Icons.delete_outline,
                                    imageUrl: eventData['imageUrl'] ?? '',
                                    eventName: eventData['title'] ?? '',
                                    currentAttendees:
                                        eventData['currentAttendees'] ?? 0,
                                    onDelete: () {
                                      deletBookedEvent(context, eventId);
                                    },
                                    eventID: eventId,
                                  );
                                },
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text('No booked events'));
                        }
                      } else {
                        return const Center(child: Text('No data available'));
                      }
                    }
                  },
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
