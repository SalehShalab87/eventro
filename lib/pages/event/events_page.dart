import 'package:eventro/components/all_events_list.dart';
import 'package:eventro/pages/main/main_page.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'All Upcomming Events',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MainPage()));
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: AllEventsList(),
      ),
    );
  }
}
