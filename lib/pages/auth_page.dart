import 'package:eventro/pages/login_page.dart';
import 'package:eventro/pages/main_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//this page initialzied after the splash screen to check if the user is signed in or out

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
