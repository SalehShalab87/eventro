// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/pages/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    // Fetch notifications for the current user from Cloud Firestore
    _notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      // Handle any errors that occur during deletion
      const ScaffoldMessenger(
          child: SnackBar(
        content: Text('Error deleting notification'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content:
              const Text('Are you sure you want to delete this notification?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainPage())),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xffEC6408),
            ));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/no_notifications.png',
                    height: 300,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'You have no notifications yet',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final notification = snapshot.data!.docs[index];
              final notificationId = notification.id;
              final eventId = notification['eventId'];
              final createdAt = notification['createdAt'] as Timestamp;
              final formattedDate =
                  DateFormat('MMM d, y').format(createdAt.toDate());

              return Dismissible(
                key: Key(notificationId),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  bool confirmDelete =
                      await _showDeleteConfirmationDialog(context);
                  if (confirmDelete) {
                    _deleteNotification(notificationId);
                  }
                },
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmationDialog(context);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('eventsCollection')
                      .doc(eventId)
                      .get(),
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircularProgressIndicator(
                          color: Color(0xffEC6408),
                        ),
                      );
                    }
                    if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                      return const ListTile(
                        leading: Icon(Icons.error),
                        title: Text('Event not found'),
                      );
                    }
                    final event = eventSnapshot.data!;
                    final eventImageUrl = event['imageUrl'];

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          eventImageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(notification['title']),
                      subtitle: Text(notification['body']),
                      trailing: Text(formattedDate),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
