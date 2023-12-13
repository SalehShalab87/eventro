import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';

class Booking extends ChangeNotifier {
  //list for the event to book
  List<Event> eventToBook = [
    Event(
        imageUrl: 'images/football.png',
        title: 'Football Event',
        price: 'Free',
        description: 'Cool Fotball Event'),
    Event(
        imageUrl: 'images/music.png',
        title: 'Music Event',
        price: 'Free',
        description: 'Cool Music Event'),
    Event(
        imageUrl: 'images/cycles.png',
        title: 'Cycles Event',
        price: 'Free',
        description: 'Cool Cycles Event'),
  ];

  //list for the user favorite
  List<Event> userFavorite = [];

  //get list of event to book
  List<Event> getUserEventToBook() {
    return eventToBook;
  }

  //get user favorite events
  List<Event> getUseFavoriteEvents() {
    return userFavorite;
  }

  //add to favorite events
  void addEventToFavorites(Event event) {
    userFavorite.add(event);
    notifyListeners();
  }

  // remove favorite events
  void deleteEventFromFavorites(Event event) {
    userFavorite.remove(event);
    notifyListeners();
  }
}
