// ignore_for_file: must_be_immutable

import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:eventro/pages/event/event_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteEvents extends StatefulWidget {
  FavoriteEvents({super.key, required this.event});
  Event event;

  @override
  State<FavoriteEvents> createState() => _FavoriteEventsState();
}

// State class for the FavoriteEvents widget
class _FavoriteEventsState extends State<FavoriteEvents> {
  // Function to show a confirmation dialog
  Future<void> showDeletConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Deletion Confirmation'),
        content: const Text(
            'Are you sure you want to delete this event from your favorites?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: _buildButton('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              removefromfav(
                  context); // Call the function to remove from favorites
            },
            child: _buildButton('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(
        color: Color(0xffEC6408),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.black)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
        ],
      ),
    );
  }

  // Function to remove the event from favorites
  void removefromfav(BuildContext context) {
    Provider.of<Booking>((context), listen: false)
        .deleteEventFromFavorites(context, widget.event);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the EventDetails page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetails(eventId: widget.event.eventId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            tileColor: Colors.grey[200],
            leading: Image.asset(
              widget.event.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            title: Text(
              widget.event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(widget.event.price),
            trailing: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: Color(0xffEC6408),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
              child: IconButton(
                onPressed: () => showDeletConfirmationDialog(context),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
