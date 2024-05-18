import 'package:eventro/pages/authpages/email_verfication.dart';
import 'package:eventro/pages/authpages/login_page.dart';
import 'package:eventro/pages/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Booking>(
      builder: (context, value, child) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null) {
                // Check the user's sign-in method
                String signInMethod = user.providerData.first.providerId;
                if (signInMethod == 'password') {
                  // User signed in with email and password
                  if (user.emailVerified) {
                    // If the email is verified, navigate to the main page
                    return const MainPage();
                  } else {
                    // If the email is not verified, navigate to the email verification page
                    return const EmailVerification();
                  }
                } else {
                  // User signed in with Facebook or Google
                  return const MainPage();
                }
              }
            }
            // If the user is not logged in, navigate to the login page
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
