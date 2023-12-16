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
  removefromfav(BuildContext context) {
    Provider.of<Booking>((context), listen: false)
        .deleteEventFromFavorites(context, widget.event);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle onTap actions if needed
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            tileColor: Colors.grey[200],
            leading: Image.asset(
              widget.event.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            title: Text(
              widget.event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(widget.event.price),
            trailing: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: Color(0xffEC6408),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
              child: IconButton(
                onPressed: () => removefromfav(context),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
