import 'package:eventro/pages/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:eventro/Services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Sign User Out Method
  void _signOut(BuildContext context) {
    signOutFromFirebase(context);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (currentUser != null)
              CircleAvatar(
                backgroundImage: NetworkImage(currentUser.photoURL ?? ''),
              ),
            const SizedBox(width: 8),
            if (currentUser != null) Text(currentUser.displayName ?? 'User'),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {
                  // Navigate to the notification page
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const NotificationPage();
                  }));
                },
                icon: const Icon(Icons.notifications),
              ),
              // Counter widget (you need to implement the logic for the counter)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '2', // Replace with your actual notification count
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              _signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Your App!'),
            if (currentUser != null)
              Text('Hi, ${currentUser.displayName ?? 'User'}'),
          ],
        ),
      ),
    );
  }
}
