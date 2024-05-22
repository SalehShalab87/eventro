import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/event_tile.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventro/pages/event/event_details.dart';

class EventListBuilder extends StatelessWidget {
  final String searchQuery;
  final String? eventTypeFilter;

  const EventListBuilder(
      {super.key, required this.searchQuery, this.eventTypeFilter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventsCollection')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xffEC6408)),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        var events =
            snapshot.data!.docs.map((doc) => Event.fromSnapshot(doc)).toList();

        // Determine the filtering logic based on input
        if (searchQuery.isNotEmpty && eventTypeFilter == null) {
          events = events
              .where((event) =>
                  event.title
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) &&
                      event.approvalStatus == 'approved' &&
                      event.dateTime!.isAfter(DateTime.now()) ||
                  event.eventType
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();
        } else if (eventTypeFilter != null && searchQuery.isEmpty) {
          events = events
              .where((event) =>
                  event.eventType == eventTypeFilter &&
                  event.approvalStatus == 'approved' &&
                  event.dateTime!.isAfter(DateTime.now()))
              .toList();
        } else {
          // Default filtering for approved and upcoming events
          events = events
              .where((event) =>
                  event.approvalStatus == 'approved' &&
                  event.dateTime!.isAfter(DateTime.now()))
              .toList();
        }
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/no_events.png',
                  height: 300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No events found',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            Event event = events[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetails(
                    eventId: event.eventId,
                  ),
                ),
              ),
              child: EventTile(
                onTap: () =>
                    context.read<Booking>().addEventToFavorite(context, event),
                event: event,
              ),
            );
          },
        );
      },
    );
  }
}
