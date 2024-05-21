// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
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

  // List for the user favorite
  List<Event> userFavorite = [];
  List<Event> eventsToBook = [];

  Future<List<Event>> getUserBookedEvents(
      BuildContext context, String userId) async {
    List<Event> bookedEvents = [];

    try {
      // Fetch all booking documents for the current user
      QuerySnapshot bookingSnapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      // Fetch each event based on eventId from the bookings
      for (var doc in bookingSnapshot.docs) {
        DocumentSnapshot eventDoc = await firestore
            .collection('eventsCollection')
            .doc(doc['eventId'])
            .get();

        if (eventDoc.exists) {
          Event event = Event.fromSnapshot(eventDoc);
          bookedEvents.add(event);
        }
      }
    } catch (e) {
      ShowErrorMessage.showError(context, 'Error fetching bookings');
      // Handle exceptions or errors as needed
    }

    return bookedEvents;
  }

  // Replace the hardcoded list with a method to fetch events from Firestore
  Future<List<Event>> getEventsToBook(BuildContext context) async {
    try {
      eventsToBook.clear(); // Clear the list before fetching new data
      QuerySnapshot querySnapshot =
          await events.where('status', isEqualTo: 'approved').get();
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
          approvalStatus: data['status'] ?? '',
          latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['long'] as num?)?.toDouble() ?? 0.0,
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
            approvalStatus: data['status'] ?? '',
            latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
            longitude: (data['long'] as num?)?.toDouble() ?? 0.0,
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
            approvalStatus: eventData['status'] ?? '',
            latitude: (eventData['lat'] as num?)?.toDouble() ?? 0.0,
            longitude: (eventData['long'] as num?)?.toDouble() ?? 0.0,
            creatorId: eventData['creatorId'] ?? '',
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

  // Get user favorite events
  List<Event> getUserFavoriteEvents() {
    return userFavorite;
  }

  // Add to favorite events
  void addEventToFavorites(Event event) {
    userFavorite.add(event);
    notifyListeners();
  }

  //delete event from favorite page for the user
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

  Future<bool> bookEvent(Event event) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in, return false
        return false;
      }

      // Check if the event is already full
      if (event.currentAttendees >= event.maxCapacity) {
        // If the event is full, return false to indicate unsuccessful booking
        return false;
      }

      // Create a booking record in Firestore
      await firestore.collection('bookings').add({
        'userId': user.uid,
        'eventId': event.eventId,
        'dateOfBooked': Timestamp.now(),
        'imageUrl': event.imageUrl,
        'title': event.title,
        'location': event.location,
        'dateTime': event.dateTime,
        'eventType': event.eventType,
        'currentAttendees': event.currentAttendees,
        'hasAtteended': false,
      });

      // Update the current attendees count for the event
      await events.doc(event.eventId).update({
        'currentAttendees': FieldValue.increment(1),
      });

      // Return true to indicate successful booking
      return true;
    } catch (e) {
      // Return false if any error occurs during booking
      return false;
    }
  }

  // check event booking status method
  Future<bool> checkEventBookingStatus(
      BuildContext context, String eventId) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in, return false
        return false;
      }

      // Query Firestore to check if the user has booked the event
      QuerySnapshot querySnapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('eventId', isEqualTo: eventId)
          .get();

      // If a booking document is found for the user and event, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle errors gracefully by displaying an error message using showErrorMessage
      ShowErrorMessage.showError(
          context, 'An error occurred while checking event booking status: $e');
      return false;
    }
  }

  Future<bool> cancelBooking(BuildContext context, String eventId) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in, return false
        return false;
      }

      // Query the bookings collection to find the booking document
      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      // Check if any booking documents are found
      if (bookingSnapshot.docs.isEmpty) {
        // If no matching booking document is found, return false
        return false;
      }

      // Get the ID of the booking document
      String bookingId = bookingSnapshot.docs.first.id;

      // Delete the record from Cloud Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();

      // Update the current attendees count for the event
      await events.doc(eventId).update({
        'currentAttendees': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      // Handle errors gracefully by displaying an error message using showErrorMessage
      ShowErrorMessage.showError(
          context, 'An error occurred while canceling event booking: $e');
      return false;
    }
  }
}
