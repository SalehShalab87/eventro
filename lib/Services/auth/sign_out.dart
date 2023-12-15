// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/show_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
