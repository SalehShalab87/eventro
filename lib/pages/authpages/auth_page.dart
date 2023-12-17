import 'package:eventro/pages/authpages/login_page.dart';
import 'package:eventro/pages/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';

//this page initialzied after the splash screen to check if the user is signed in or out

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
        builder: (context, value, child) => Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //is the user loged in
          if (snapshot.hasData) {
            return const MainPage();
          }

          //is the user not loged in
          else {
            return const LoginPage();
          }
        },
      ),
    ));
  }
}
