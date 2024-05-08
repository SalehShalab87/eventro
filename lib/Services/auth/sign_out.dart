// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/show_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> signOutFromFirebase(BuildContext context) async {
  try {
    // Show the sign-out confirmation dialog
    bool shouldSignOut = await showSignOutConfirmationDialog(context);

    // Check if the user confirmed the sign-out
    if (shouldSignOut) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  } catch (e) {
    String errorMessage = "Failed to sign out from Firebase.";
    if (e is FirebaseAuthException) {
      errorMessage = e.message ?? errorMessage;
    }
    ShowErrorMessage(message: errorMessage);
  }
}

Future<bool> showSignOutConfirmationDialog(BuildContext context) async {
  // Return a Future<bool> to indicate whether the user confirmed the sign-out
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Sign Out Confirmation'),
          content: const Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false); // Close the dialog and return false
              },
              child: _buildSignOutButton('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true); // Close the dialog and return true
              },
              child: _buildSignOutButton('Yes'),
            ),
          ],
        ),
      ) ??
      false; // Provide a default value if the user dismisses the dialog
}

Widget _buildSignOutButton(String text) {
  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.symmetric(horizontal: 20.0),
    decoration: const BoxDecoration(
      color: Color(0xffEC6408),
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(color: Colors.black)),
        const SizedBox(width: 5),
        const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
      ],
    ),
  );
}
