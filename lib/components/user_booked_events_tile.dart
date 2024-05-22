import 'package:eventro/pages/event/event_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserBookedEventsTile extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String eventID;
  final int currentAttendees;
  final VoidCallback onDelete;
  final IconData icon;

  const UserBookedEventsTile({
    super.key,
    required this.imageUrl,
    required this.eventName,
    required this.currentAttendees,
    required this.onDelete,
    required this.eventID,
    required this.icon,
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
        child: ListTile(
          leading: imageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 30,
                )
              : const Placeholder(), // Placeholder for image if imageUrl is empty
          title: Text(eventName),
          subtitle: Text('Attendees: $currentAttendees'),
          trailing: Container(
            decoration: const BoxDecoration(
                color: Color(0xffEC6408),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            child: IconButton(
              onPressed: onDelete,
              icon: Icon(
                icon,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
