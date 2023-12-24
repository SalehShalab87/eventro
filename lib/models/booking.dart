// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking extends ChangeNotifier {
  // Create an object for the firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collection for the events
  CollectionReference events =
      FirebaseFirestore.instance.collection('eventsCollection');

  // Replace the hardcoded list with a method to fetch events from Firestore
  Future<List<Event>> getEventsToBook(BuildContext context) async {
    try {
      eventsToBook.clear(); // Clear the list before fetching new data
      QuerySnapshot querySnapshot = await events.get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Event event = Event(
          maxCapacity: data['maxCapacity'] ?? 0,
          currentAttendees: data['currentAttendees'] ?? 0,
          eventId: doc.id,
          imageUrl: data['imageUrl'] ?? '',
          location: data['location'] ?? '',
          title: data['title'] ?? '',
          dateTime: (data['datetime'] as Timestamp?)
              ?.toDate(), // Convert Timestamp to DateTime
          price: data['price'] ?? '',
          description: data['description'] ?? '',
          eventType: data['eventType'] ?? '',
        );
        eventsToBook.add(event);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred while fetching events.'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
    return eventsToBook;
  }

  // Fetch user favorite events from Firestore during initialization
  Future<void> init(BuildContext context) async {
    await fetchUserFavoriteEvents(context);
  }

  // Fetch user favorite events from Firestore
  Future<void> fetchUserFavoriteEvents(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favoriteEvents')
            .get();

        userFavorite.clear(); // Clear the list before fetching new data

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Event event = Event(
            maxCapacity: data['maxCapacity'] ?? 0,
            currentAttendees: data['currentAttendees'] ?? 0,
            eventId: doc.id,
            imageUrl: data['imageUrl'] ?? '',
            location: data['location'] ?? '',
            title: data['title'] ?? '',
            dateTime: (data['datetime'] as Timestamp?)
                ?.toDate(), // Convert Timestamp to DateTime
            price: data['price'] ?? '',
            description: data['description'] ?? '',
            eventType: data['eventType'] ?? '',
          );
          userFavorite.add(event);
        }

        notifyListeners();
      }
    } catch (e) {
      // Handle Firestore error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'An error occurred while fetching user favorite events.'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }

  Future<void> addEventToFavorite(BuildContext context, Event event) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        bool isAlreadyInFavorites =
            userFavorite.any((favEvent) => favEvent.eventId == event.eventId);

        if (!isAlreadyInFavorites) {
          userFavorite.add(event);

          // Add the event to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('favoriteEvents')
              .doc(event.eventId)
              .set(event.toMap());

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Successfully added!'),
              content: const Text('Check the favorite page'),
              actions: [
                MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Event already added!'),
              content: const Text('This event is already in your favorites.'),
              actions: [
                MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
              ],
            ),
          );
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'An error occurred while adding the event to favorites.'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }

  // Fetch event details based on eventId
  Stream<Event?> getEventDetailsStream(BuildContext context, String eventId) {
    try {
      // Reference to the event document in Firestore
      Stream<DocumentSnapshot> eventStream = events
          .doc(eventId)
          .snapshots(); // Use snapshots to get real-time updates

      return eventStream.map((eventSnapshot) {
        // Check if the document exists
        if (eventSnapshot.exists) {
          // Extract data from the document
          Map<String, dynamic> eventData =
              eventSnapshot.data() as Map<String, dynamic>;

          // Create an Event object with the extracted data
          Event event = Event(
            maxCapacity: eventData['maxCapacity'] ?? 0,
            currentAttendees: eventData['currentAttendees'] ?? 0,
            eventId: eventId,
            imageUrl: eventData['imageUrl'] ?? '',
            location: eventData['location'] ?? '',
            title: eventData['title'] ?? '',
            dateTime: (eventData['datetime'] as Timestamp?)
                ?.toDate(), // Convert Timestamp to DateTime
            price: eventData['price'] ?? '',
            description: eventData['description'] ?? '',
            eventType: eventData['eventType'] ?? '',
          );

          return event;
        } else {
          // Return null if the document doesn't exist
          return null;
        }
      });
    } catch (e) {
      // Handle any errors that may occur during the fetch
      // Display a dialog with an error message
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
      return Stream.value(null);
    }
  }

  // List for the user favorite
  List<Event> userFavorite = [];
  List<Event> eventsToBook = [];

  // Get user favorite events
  List<Event> getUserFavoriteEvents() {
    return userFavorite;
  }

  // Add to favorite events
  void addEventToFavorites(Event event) {
    userFavorite.add(event);
    notifyListeners();
  }

  //delte event from favoriet paeg for the user
  Future<void> deleteEventFromFavorites(
      BuildContext context, Event event) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Remove the event from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favoriteEvents')
            .doc(event.eventId)
            .delete();

        // Remove the event from the local list
        userFavorite.remove(event);

        notifyListeners();
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'An error occurred while removing the event from favorites.'),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        ),
      );
    }
  }
}
