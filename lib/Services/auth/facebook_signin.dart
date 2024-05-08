// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:eventro/components/show_loadingcircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookServices {
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

        showLoadingCircle(context);

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
          const ShowErrorMessage(
              message: "Facebook Sign-In failed. User not found.");
        }
      } else {
        const ShowErrorMessage(
            message: "Facebook Sign-In failed. Access token is null.");
      }
    } catch (e) {
      ShowErrorMessage(message: e.toString());
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
      ShowErrorMessage(message: e.toString());
    }
  }
}
