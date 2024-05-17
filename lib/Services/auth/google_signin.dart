import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/show_loadingcircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleServices {
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
      if (context.mounted) {
        showLoadingCircle(context);
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final name = user.displayName ?? 'null';
        final email = user.providerData[0].email ?? 'null';
        final profilePictureUrl = user.photoURL ?? 'null';

        await saveUserDetailsToFirestore(
            name, user.uid, email, profilePictureUrl);

        if (FirebaseAuth.instance.currentUser != null && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        } else if (context.mounted) {
          showError(context, "Google Sign-In failed. User not found.");
        }
      }
    } catch (e) {
      if (context.mounted) {
        showError(context, e.toString());
      }
    }
  }

  Future<void> saveUserDetailsToFirestore(
      String name, String uid, String email, String profilePictureUrl) async {
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
      // Handle error, no need for context here since it's Firestore operation
      print("Error saving user details to Firestore: $e");
    }
  }

  void showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
