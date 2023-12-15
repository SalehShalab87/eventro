// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
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

      _showLoadingCircle(context);

      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final name = user.displayName ?? 'null';
        final email = user.providerData[0].email ?? 'null';
        final profilePictureUrl = user.photoURL ?? 'null';

        await saveUserDetailsToFirestore(
            context, name, user.uid, email, profilePictureUrl);
      }

      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showErrorMessage(context, "Google Sign-In failed. User not found.");
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage(context, e.toString());
    }
  }

  Future<void> saveUserDetailsToFirestore(BuildContext context, String name,
      String uid, String email, String profilePictureUrl) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userCollection = firestore.collection('users');

      final collectionExists = await userCollection.doc(uid).get();
      if (!collectionExists.exists) {
        await userCollection.doc(uid).set({
          'name': name,
          'email': email,
          'photoURL': profilePictureUrl,
        });
      }
    } catch (e) {
      showErrorMessage(context, e.toString());
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        return;
      }

      if (loginResult.accessToken != null) {
        final AccessToken accessToken = loginResult.accessToken!;
        final facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.token);

        _showLoadingCircle(context);

        await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        final userData = await FacebookAuth.instance.getUserData();
        final name = userData['name'] ?? '';
        final email = userData['email'] ?? '';
        final profilePictureUrl = userData['picture']['data']['url'] ?? '';

        await saveFUserDetailsToFirestore(context, name,
            FirebaseAuth.instance.currentUser!.uid, email, profilePictureUrl);

        Navigator.pop(context);

        if (FirebaseAuth.instance.currentUser != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          showErrorMessage(context, "Facebook Sign-In failed. User not found.");
        }
      } else {
        showErrorMessage(
            context, "Facebook Sign-In failed. Access token is null.");
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage(context, e.toString());
    }
  }

  Future<void> saveFUserDetailsToFirestore(BuildContext context, String name,
      String uid, String email, String profilePictureUrl) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userCollection = firestore.collection('users');

      final collectionExists = await userCollection.doc(uid).get();
      if (!collectionExists.exists) {
        await userCollection.doc(uid).set({
          'name': name,
          'email': email,
          'photoURL': profilePictureUrl,
        });
      }
    } catch (e) {
      showErrorMessage(context, e.toString());
    }
  }

  // The rest of your code remains unchanged...
}

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

void _showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: Color(0xffEC6408)),
    ),
    barrierDismissible: false,
  );
}
