// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/models/event.dart';
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
          id: doc.id,
          imageUrl: data['imageUrl'] ?? '',
          title: data['title'] ?? '',
          price: data['price'] ?? '',
          description: data['description'] ?? '',
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

  // List for the user favorite
  List<Event> userFavorite = [];
  List<Event> eventsToBook = [];

  // Get user favorite events
  List<Event> getUseFavoriteEvents() {
    return userFavorite;
  }

  // Add to favorite events
  void addEventToFavorites(Event event) {
    userFavorite.add(event);
    notifyListeners();
  }

  // Remove favorite events
  void deleteEventFromFavorites(Event event) {
    userFavorite.remove(event);
    notifyListeners();
  }
}
