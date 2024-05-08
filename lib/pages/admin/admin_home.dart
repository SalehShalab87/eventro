import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Stream<int> userCountStream;
  late Stream<int> eventCountStream;
  late Stream<int> pendingEventCountStream;

  @override
  void initState() {
    super.initState();
    userCountStream = _getUserCountStream();
    eventCountStream = _getEventCountStream();
    pendingEventCountStream = _getPendingEventCountStream();
  }

  Stream<int> _getUserCountStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _getEventCountStream() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _getPendingEventCountStream() {
    return FirebaseFirestore.instance
        .collection('eventsCollection')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StreamBuilder<int>(
                  stream: userCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xffEC6408),
                      );
                    }
                    return AdminCountCard(
                      count: snapshot.data ?? 0,
                      title: 'Users',
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: eventCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xffEC6408),
                      );
                    }
                    return AdminCountCard(
                      count: snapshot.data ?? 0,
                      title: 'Events',
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: pendingEventCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xffEC6408),
                      );
                    }
                    return AdminCountCard(
                      count: snapshot.data ?? 0,
                      title: 'Pending Events',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminCountCard extends StatelessWidget {
  final int count;
  final String title;

  const AdminCountCard({
    super.key,
    required this.count,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
