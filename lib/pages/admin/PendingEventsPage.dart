// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PendingEventsPage extends StatefulWidget {
  const PendingEventsPage({super.key});

  @override
  State<PendingEventsPage> createState() => _PendingEventsPageState();
}

class _PendingEventsPageState extends State<PendingEventsPage> {
  late Stream<List<Event>> pendingEventStream;

  @override
  void initState() {
    super.initState();
    pendingEventStream = _getPendingEventStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pending Events',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<List<Event>>(
          stream: pendingEventStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xffEC6408)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Pending events available.'));
            }
            return Column(
              children: snapshot.data!.map((event) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          event.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          event.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Type: ${event.eventType}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Location: ${event.location}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Date: ${event.dateTime != null ? DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(event.dateTime!.millisecondsSinceEpoch)) : "Unknown"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _rejectEvent(event),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                child: const Text('R E J E C T'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptEvent(event),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white),
                                child: const Text('A C C E P T'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Stream<List<Event>> _getPendingEventStream() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList());
  }

  void _acceptEvent(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Accept Event"),
          content: const Text("Are you sure you want to accept this event?"),
          actions: [
            MyButton(
                onTap: () {
                  _updateEventStatus(event, 'approved', '');
                  Navigator.pop(context);
                },
                text: 'Yes'),
            const SizedBox(height: 10),
            MyButton(onTap: () => Navigator.pop(context), text: 'No'),
          ],
        );
      },
    );
  }

  void _rejectEvent(Event event) {
    String rejectionReason = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reject Event"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Are you sure you want to reject this event?"),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextFormField(
                  cursorColor: const Color(0xffEC6408),
                  decoration: const InputDecoration(
                    hintText: 'Reason for rejection',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    rejectionReason =
                        value; // Save the reason entered by the admin
                  },
                ),
              ),
            ],
          ),
          actions: [
            MyButton(
              onTap: () {
                if (rejectionReason.isNotEmpty) {
                  _updateEventStatus(event, 'rejected', rejectionReason);
                  Navigator.pop(context);
                } else {
                  // Show error message if rejection reason is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Please enter a reason for rejection.',
                      ),
                    ),
                  );
                }
              },
              text: 'Yes',
            ),
            const SizedBox(height: 10),
            MyButton(
              onTap: () => Navigator.pop(context),
              text: 'No',
            ),
          ],
        );
      },
    );
  }

  void _updateEventStatus(Event event, String status, String rejectionReason) {
    FirebaseFirestore.instance
        .collection('eventsCollection')
        .doc(event.eventId)
        .update({
      'status': status,
      'rejectionReason':
          rejectionReason, // Save the rejection reason in Firestore
    });
  }
}
