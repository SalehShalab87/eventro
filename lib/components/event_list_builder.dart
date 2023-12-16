// ignore_for_file: use_build_context_synchronously
import 'package:eventro/components/event_tile.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventro/pages/event/event_details.dart';

class EventListBuilder extends StatefulWidget {
  const EventListBuilder({super.key});

  @override
  State<EventListBuilder> createState() => _EventListBuilderState();
}

class _EventListBuilderState extends State<EventListBuilder> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: Provider.of<Booking>(context).getEventsToBook(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while waiting for data
          return const Center(
            child: CircularProgressIndicator(color: Color(0xffEC6408)),
          );
        } else if (snapshot.hasError) {
          // Display an error message if there's an issue fetching data
          return Text('Error: ${snapshot.error}');
        } else {
          // If data is available, build the horizontal list view
          List<Event> events = snapshot.data!;
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
                  onTap: () => context
                      .read<Booking>()
                      .addEventToFavorite(context, event),
                  event: event,
                ),
              );
            },
          );
        }
      },
    );
  }
}
