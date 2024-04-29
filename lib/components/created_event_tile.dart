import 'package:eventro/models/event.dart';
import 'package:eventro/pages/event/event_details.dart';
import 'package:flutter/material.dart';

class CreatedEventTile extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String eventID;
  final int currentAttendees;
  final VoidCallback onDelete;

  const CreatedEventTile({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.currentAttendees,
    required this.onDelete,
    required this.eventID,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the EventDetails page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetails(eventId: eventID),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ListTile(
          leading: imageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 30,
                )
              : const Placeholder(), // Placeholder for image if imageUrl is empty
          title: Text(eventName),
          subtitle: Text('Current Attendees: $currentAttendees'),
          trailing: Container(
            decoration: const BoxDecoration(
                color: Color(0xffEC6408),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
