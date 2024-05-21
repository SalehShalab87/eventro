import 'package:eventro/pages/event/event_details.dart';
import 'package:flutter/material.dart';

class CreatedEventTile extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final String eventID;
  final String status;
  final String rejectionReason;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final IconData icon;

  const CreatedEventTile(
      {super.key,
      required this.imageUrl,
      required this.eventName,
      required this.status,
      required this.onDelete,
      required this.eventID,
      required this.icon,
      this.rejectionReason = '',
      required this.onEdit});

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
          subtitle: status == 'rejected'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $status'),
                    const SizedBox(height: 5),
                    Text(
                      'Rejection Reason: $rejectionReason',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                )
              : Text('Status: $status'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xffEC6408),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xffEC6408),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    icon,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
