import 'package:eventro/components/favorite_event.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
        builder: (context, value, child) => Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    'My Favorites',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )),
              //list view for the favorites
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.getUseFavoriteEvents().length,
                        itemBuilder: (BuildContext context, int index) {
                          // get invidual event
                          Event individualEvent =
                              value.getUseFavoriteEvents()[index];
                          //return the favorite event
                          return FavoriteEvents(
                            event: individualEvent,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
