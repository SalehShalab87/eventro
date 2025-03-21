// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class EventDetails extends StatefulWidget {
  final String eventId;

  const EventDetails({super.key, required this.eventId});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Stream<Event?> eventStream;
  bool isEventBooked = false;
  bool _isMapVisible = false;
  String? currentUserId;
  Event? currentevent;

  @override
  void initState() {
    super.initState();
    eventStream = Booking().getEventDetailsStream(context, widget.eventId);
    checkEventBookingStatus();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isMapVisible = true;
      });
    });
    // Get the current user's ID
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> checkEventBookingStatus() async {
    bool booked =
        await Booking().checkEventBookingStatus(context, widget.eventId);

    setState(() {
      isEventBooked = booked;
    });
  }

  Future<bool> checkForDateTimeConflicts(DateTime newEventDateTime) async {
    if (currentUserId == null) {
      // Return false or handle appropriately if there is no user
      return false;
    }

    List<Event> userEvents =
        await Booking().getUserBookedEvents(context, currentUserId!);
    for (Event bookedEvent in userEvents) {
      if (bookedEvent.dateTime!.isAtSameMomentAs(newEventDateTime)) {
        return true; // Conflict found
      }
    }
    return false; // No conflict
  }

  Future<void> bookEvent(Event event) async {
    // First, check if the user has already booked any event at the same date and time
    bool hasConflict = await checkForDateTimeConflicts(event.dateTime!);

    if (hasConflict) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Booking Conflict'),
          content: const Text('You have already booked an event at this time.'),
          actions: <Widget>[
            MyButton(
              onTap: () => Navigator.of(context).pop(),
              text: 'OK',
            ),
          ],
        ),
      );
      return;
    }

    // Get the event document from Firestore
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('eventsCollection')
        .doc(event.eventId)
        .get();

    // Check if the event document exists
    if (eventSnapshot.exists) {
      // Get the creator ID from the event document
      String creatorId = eventSnapshot.get('creatorId');

      // Check if the current user is the event creator
      if (currentUserId == creatorId) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cannot Book Event'),
            content: const Text(
                'As the event creator, you cannot book your own event.'),
            actions: [
              MyButton(
                onTap: () => Navigator.pop(context),
                text: 'OK',
              ),
            ],
          ),
        );
        return;
      }
    }
    if (isEventBooked) {
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

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: const Text('Do you want to book this event?'),
        actions: [
          MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
          const SizedBox(height: 10),
          MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
        ],
      ),
    );

    if (confirm != null && confirm) {
      bool success = await Booking().bookEvent(event);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Event booked successfully!... Check MyEvents Page'),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          isEventBooked = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to book the event'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> cancelBooking(Event event) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancel Booking'),
        content: const Text('Do you want to cancel this booking?'),
        actions: [
          MyButton(onTap: () => Navigator.pop(context, true), text: 'Yes'),
          const SizedBox(height: 10),
          MyButton(onTap: () => Navigator.pop(context, false), text: 'No'),
        ],
      ),
    );

    if (confirm != null && confirm) {
      bool success = await Booking().cancelBooking(context, event.eventId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Booking cancelled successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          isEventBooked = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content:
                Text('Failed to cancel the booking. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> setEventReminder(Event event) async {
    // Request notification permissions if not already granted
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Show a bottom sheet with reminder options
    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Set Event Reminder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('1 hour before'),
                  leading: Radio<int>(
                    activeColor: const Color(0xffEC6408),
                    value: 1,
                    groupValue: _selectedReminderOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderOption = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('1 day before'),
                  leading: Radio<int>(
                    activeColor: const Color(0xffEC6408),
                    value: 24,
                    groupValue: _selectedReminderOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderOption = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('2 days before'),
                  leading: Radio<int>(
                    activeColor: const Color(0xffEC6408),
                    value: 48,
                    groupValue: _selectedReminderOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderOption = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('a week before'),
                  leading: Radio<int>(
                    activeColor: const Color(0xffEC6408),
                    value: 168,
                    groupValue: _selectedReminderOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderOption = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Color(0xffEC6408))),
                  onPressed: () {
                    Navigator.pop(context);
                    _scheduleReminder(event, _selectedReminderOption);
                  },
                  child: const Text(
                    'Set Reminder',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _selectedReminderOption = 24; // Default reminder option

  Future<void> _scheduleReminder(Event event, int hoursBefore) async {
    DateTime reminderTime =
        event.dateTime!.subtract(Duration(hours: hoursBefore));

    // Create the notification content
    NotificationContent content = NotificationContent(
      id: event.hashCode,
      channelKey: 'basic_channel',
      title: 'Event Reminder',
      body: hoursBefore > 48
          ? 'Reminder: ${event.title} is starting in ${hoursBefore ~/ 24} days'
          : 'Reminder: ${event.title} is starting in $hoursBefore hours',
      notificationLayout: NotificationLayout.BigText,
    );

    // Schedule the notification
    await AwesomeNotifications().createNotification(
      content: content,
      //TODO schedule: NotificationCalendar.fromDate(date: reminderTime),
    );

    // Upload the notification to Cloud Firestore
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'eventId': event.eventId,
      'title': content.title,
      'body': content.body,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Event reminder set successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: currentUserId != null,
              child: IconButton(
                  iconSize: 28,
                  onPressed: () {
                    if (currentevent != null) {
                      setEventReminder(currentevent!);
                    }
                  },
                  icon: const Icon(
                    Icons.notification_add_outlined,
                    color: Colors.black,
                  )),
            ),
          ),
        ],
        title: const Text(
          'Event details',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Error fetching event details.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            eventStream = Booking()
                                .getEventDetailsStream(context, widget.eventId);
                          });
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text('Retry'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                currentevent = snapshot.data!;
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
                        fit: BoxFit.fill,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Price: ${event.price}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.event, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Event Type: ${event.eventType}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Location: ${event.location}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(event.dateTime!)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Time: ${DateFormat('HH:mm:ss').format(event.dateTime!)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Current Attendees: ${event.currentAttendees.toString()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Max Capacity: ${event.maxCapacity.toString()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.description, color: Colors.black87),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Description: ${event.description}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: _isMapVisible,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 300,
                            child: GoogleMap(
                              zoomGesturesEnabled: true,
                              tiltGesturesEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(event.latitude, event.longitude),
                                zoom: 14,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(event.eventId),
                                  position:
                                      LatLng(event.latitude, event.longitude),
                                  infoWindow: InfoWindow(
                                    title: event.title,
                                    snippet: event.description,
                                  ),
                                ),
                              },
                              mapType: MapType.normal,
                              myLocationButtonEnabled: false,
                              gestureRecognizers: {
                                Factory<EagerGestureRecognizer>(
                                    () => EagerGestureRecognizer())
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: currentUserId != null &&
                          currentUserId != event.creatorId,
                      child: MyButton(
                        onTap: () {
                          if (isEventBooked) {
                            cancelBooking(event);
                          } else {
                            bookEvent(event);
                          }
                        },
                        text: isEventBooked ? 'Cancel Booking' : 'Book Now',
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
