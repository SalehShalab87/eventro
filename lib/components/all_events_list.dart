import 'package:eventro/components/event_tile_events.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:eventro/pages/event/event_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllEventsList extends StatefulWidget {
  const AllEventsList({super.key});

  @override
  State<AllEventsList> createState() => _AllEventsListState();
}

class _AllEventsListState extends State<AllEventsList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      // FutureBuilder widget to asynchronously fetch and display events
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
            scrollDirection: Axis.vertical,
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              Event event = events[index];
              return GestureDetector(
                // Navigate to the EventDetails page when an event is tapped
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetails(
                      eventId: event.eventId,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    EventTileAll(
                      // Add event to favorites when the tile is tapped
                      onTap: () => context
                          .read<Booking>()
                          .addEventToFavorite(context, event),
                      event: event,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
