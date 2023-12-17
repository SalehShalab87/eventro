// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetails extends StatefulWidget {
  final String eventId;

  const EventDetails({super.key, required this.eventId});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  Event? event; // Use nullable Event to represent that it might be null
  @override
  void initState() {
    super.initState();
    // Fetch event details when the widget is initialized
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      // Fetch event details based on the eventId
      event = await Booking().getEventDetails(context, widget.eventId);
      // Update the UI with the fetched event details
      setState(() {});
    } catch (e) {
      // Handle Firestore error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('An error occurred while fetching event details.'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event details',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: event != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the event image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      event!.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display event details such as title, price, location, date, and time
                  Text(
                    event!.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ${event!.price}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${event!.location}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display date
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(event!.dateTime!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display time
                  Text(
                    'Time: ${DateFormat('HH:mm:ss').format(event!.dateTime!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${event!.description}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Booking button
                  MyButton(
                    onTap: () {
                      // Implement your booking logic here
                      // You can navigate to a booking page or perform any other action
                    },
                    text: 'Book Now',
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
