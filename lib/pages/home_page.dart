// ignore_for_file: non_constant_identifier_names

import 'package:eventro/Services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key,});

  // Sign User Out Method
  @override
  Widget build(BuildContext context) {
    // Retrieve the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                signOutFromFirebase(context);
              },
              icon: const Icon(Icons.logout),
            )
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
      ),
    );
  }
}
