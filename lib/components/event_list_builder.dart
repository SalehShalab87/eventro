import 'package:eventro/components/event_tile.dart';
import 'package:eventro/components/my_button.dart';
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
// Add event to favorites with improved duplicate check using unique id
  void addEventToFavorite(Event event) {
    Booking booking = Provider.of<Booking>(context, listen: false);

    // Check if the event is already in favorites based on the unique id
    bool isAlreadyInFavorites = booking
        .getUseFavoriteEvents()
        .any((favEvent) => favEvent.eventId == event.eventId);

    if (!isAlreadyInFavorites) {
      // If not, add it to favorites
      booking.addEventToFavorites(event);

      // Alert the user that the event has been added to the favorites page
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
    } else {
      // If the event is already in favorites, show a warning
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Event already added!'),
          content: const Text('This event is already in your favorites.'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }

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
                    builder: (context) => const EventDetails(),
                  ),
                ),
                child: EventTile(
                  onTap: () => addEventToFavorite(event),
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
