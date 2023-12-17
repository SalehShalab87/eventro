import 'package:eventro/components/favorite_tile.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer widget to listen to changes in the Booking model
    return Consumer<Booking>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'My Favorites',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        // Body of the Favorite Page
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              // Expanded ListView to display favorite events
              Expanded(
                child: ListView.builder(
                  itemCount: value.getUserFavoriteEvents().length,
                  itemBuilder: (BuildContext context, int index) {
                    // Get individual event from the list of favorites
                    Event individualEvent =
                        value.getUserFavoriteEvents()[index];
                    // Return the FavoriteEvents widget for each event
                    return FavoriteEvents(
                      event: individualEvent,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
