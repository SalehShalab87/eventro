// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/show_error_message.dart';
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

      showLoadingCircle(context);

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
}
