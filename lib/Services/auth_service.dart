// Ignore linter rules for constant identifier names and synchronous build context usage
// These rules are ignored for specific reasons in this file.

// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:eventro/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Authentication service class
class AuthService {
  // Google sign-in method
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        return; // Exit if user cancels sign-in
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Show loading circle before asynchronous operation
      _showLoadingCircle(context);

      // Simulate an asynchronous operation
      await Future.delayed(const Duration(seconds: 1));

      // Close loading circle after asynchronous operation
      Navigator.pop(context);

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showErrorMassage(context, "Google Sign-In failed. User not found.");
      }
    } catch (e) {
      // Close loading circle in case of an error
      Navigator.pop(context);

      showErrorMassage(context, e.toString());
    }
  }

  // Display error message dialog
  void showErrorMassage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [MyButton(onTap: () => Navigator.pop(context), text: 'OK')],
        );
      },
    );
  }

  // Facebook sign-in method
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Check if the sign-in process was canceled
      if (loginResult.status != LoginStatus.success) {
        return; // Exit if user cancels sign-in
      }

      // Ensure that loginResult.accessToken is not null before using ! operator
      if (loginResult.accessToken != null) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Show loading circle
        _showLoadingCircle(context);

        // Sign in to Firebase with the Facebook credential
        await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        // Pop the loading circle
        Navigator.pop(context);

        // Check if sign-in is successful
        if (FirebaseAuth.instance.currentUser != null) {
          // Navigate to the home screen
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Handle the case where the user is not signed in
          // Show an error message or take appropriate action
          showErrorMessage(context, "Facebook Sign-In failed. User not found.");
        }
      } else {
        // Handle the case where accessToken is null
        showErrorMessage(
            context, "Facebook Sign-In failed. Access token is null.");
      }
    } catch (e) {
      // Pop the loading circle in case of an error
      Navigator.pop(context);

      // Show an error message
      showErrorMessage(context, e.toString());
    }
  }

  // Display error message dialog
  void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [MyButton(onTap: () => Navigator.pop(context), text: 'OK')],
        );
      },
    );
  }

  // Placeholder method for Apple sign-in (needs implementation)
  void signInWithApple() {
    // To be implemented
  }
}

// Sign-out method
Future<void> signOutFromFirebase(BuildContext context) async {
  try {
    await showSignOutConfirmationDialog(context);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    String errorMessage = "Failed to sign out from Firebase.";
    if (e is FirebaseAuthException) {
      errorMessage = e.message ?? errorMessage;
    }
    showErrorMessage(context, errorMessage);
  }
}

// Display sign-out confirmation dialog
Future<void> showSignOutConfirmationDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Sign Out Confirmation'),
      content: const Text('Are you sure you want to sign out?'),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: _buildSignOutButton(),
          ),
        ),
      ],
    ),
  );
}

// Build the sign-out button widget
Widget _buildSignOutButton() {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.symmetric(horizontal: 20.0),
    decoration: const BoxDecoration(
      color: Color(0xffEC6408),
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Sign Out', style: TextStyle(color: Colors.black)),
        SizedBox(width: 5),
        Icon(Icons.arrow_forward, color: Colors.black, size: 18),
      ],
    ),
  );
}

// Display error message dialog
void showErrorMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [MyButton(onTap: () => Navigator.pop(context), text: 'OK')],
    ),
  );
}

// Display loading circle
void _showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: Color(0xffEC6408)),
    ),
    barrierDismissible: false,
  );
}
