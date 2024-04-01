// ignore_for_file: must_be_immutable

import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';

class EventTileAll extends StatelessWidget {
  EventTileAll({super.key, required this.event, required this.onTap});
  Event event;

  //add to favorite function
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        height: 400,
        width: 350,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // event pic
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.imageUrl,
                  width: double.infinity,
                  height: 310,
                  fit: BoxFit.cover,
                ),
              ),
              //price + deatails
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //event title
                        Text(
                          event.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        // price
                        Text(event.price),
                      ],
                    ),
                    //favorite button
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                            color: Color(0xffEC6408),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12))),
                        child: const Icon(Icons.favorite_border_outlined),
                      ),
                    )
                  ],
                ),
              )
              // favorite button
            ]),
      ),
    );
  }
}
