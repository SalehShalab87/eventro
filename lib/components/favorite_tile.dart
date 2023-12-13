// ignore_for_file: must_be_immutable

import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteEvents extends StatefulWidget {
  FavoriteEvents({super.key, required this.event});
  Event event;

  @override
  State<FavoriteEvents> createState() => _FavoriteEventsState();
}
//remove event from favorites

class _FavoriteEventsState extends State<FavoriteEvents> {
  removefromfav() {
    Provider.of<Booking>((context), listen: false)
        .deleteEventFromFavorites(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
          leading: Image.asset(widget.event.imageUrl),
          title: Text(widget.event.title),
          subtitle: Text(widget.event.price),
          trailing: IconButton(
              onPressed: () => removefromfav(),
              icon: const Icon(Icons.delete_outline_rounded))),
    );
  }
}
