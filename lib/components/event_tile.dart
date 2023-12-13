// ignore_for_file: must_be_immutable

import 'package:eventro/components/event_deatails.dart';
import 'package:flutter/material.dart';

class EventTile extends StatelessWidget {
  EventTile({super.key, required this.event});
  Event event;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25),
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          //event image
          Image.asset(event.imagePath),

          //description

          //price + details

          //button to book
        ],
      ),
    );
  }
}
