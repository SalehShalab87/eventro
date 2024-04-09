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
  late Stream<Event?> eventStream;
  bool isEventBooked = false;

  @override
  void initState() {
    super.initState();
    eventStream = Booking().getEventDetailsStream(context, widget.eventId);
    checkEventBookingStatus();
  }

  //check booking status
  Future<void> checkEventBookingStatus() async {
    // Fetch the booking status of the event
    bool booked =
        await Booking().checkEventBookingStatus(context, widget.eventId);

    setState(() {
      isEventBooked = booked;
    });
  }

  Future<void> bookEvent(Event event) async {
    if (isEventBooked) {
      // If event is already booked, show alert dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Event Already Booked'),
          content: const Text(
              'You have already booked this event. Check My Events Page'),
          actions: [
            MyButton(
              onTap: () => Navigator.pop(context),
              text: 'OK ->',
            ),
          ],
        ),
      );
      return;
    }

    bool success = await Booking().bookEvent(event);

    if (success) {
      // If booking is successful, send notification

      //Booking().sendNotification(event);**********************

      // Show snackbar for successful booking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Event booked successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Update state to reflect booking status
      setState(() {
        isEventBooked = true;
      });
    } else {
      // If booking fails, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to book the event. Please try again later.'),
          duration: Duration(seconds: 2),
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
        child: StreamBuilder<Event?>(
          stream: eventStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xffEC6408),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
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
              final event = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(event.dateTime!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  Text(
                    'Description: ${event.description}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MyButton(
                    onTap: () => bookEvent(event),
                    text: isEventBooked ? 'Event Booked' : 'Book Now',
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
