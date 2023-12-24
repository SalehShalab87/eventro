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
  late Stream<Event?> eventStream;

  @override
  void initState() {
    super.initState();
    // Initialize the Stream in initState
    eventStream = Booking().getEventDetailsStream(context, widget.eventId);
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
        child: StreamBuilder<Event?>(
          stream: eventStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading state
              return const Center(
                  child: CircularProgressIndicator(
                color: Color(0xffEC6408),
              ));
            } else if (snapshot.hasError || snapshot.data == null) {
              // Error state
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Error fetching event details.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Retry fetching the event details
                          eventStream = Booking()
                              .getEventDetailsStream(context, widget.eventId);
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              // Successful state
              final event = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the event image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      event.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display event details such as title, eventType, price, location, date, and time
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Price: ${event.price}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Event Type: ${event.eventType}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${event.location}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display date
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(event.dateTime!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display time
                  Text(
                    'Time: ${DateFormat('HH:mm:ss').format(event.dateTime!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Attendees: ${event.currentAttendees.toString()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max Capacity: ${event.maxCapacity.toString()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display description
                  Text(
                    'Description: ${event.description}',
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
              );
            }
          },
        ),
      ),
    );
  }
}
