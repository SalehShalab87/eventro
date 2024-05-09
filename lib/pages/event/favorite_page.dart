import 'package:eventro/components/favorite_tile.dart';
import 'package:eventro/models/booking.dart';
import 'package:eventro/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
      builder: (context, value, child) {
        // Check if the list of favorite events is empty
        if (value.getUserFavoriteEvents().isEmpty) {
          // Show a message widget if the list is empty
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'My Favorites',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/favorite.png', height: 300),
                    const SizedBox(height: 40),
                    const Text(
                      'You have no favorite events.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Show the list of favorite events if it's not empty
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'My Favorites',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: value.getUserFavoriteEvents().length,
                      itemBuilder: (BuildContext context, int index) {
                        Event individualEvent =
                            value.getUserFavoriteEvents()[index];
                        return FavoriteEvents(
                          event: individualEvent,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
