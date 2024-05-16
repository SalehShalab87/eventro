// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Email Sent'),
            content: const Text('A verification email has been sent.'),
            actions: [
              MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
            ],
          );
        },
      );
    } catch (e) {
      ShowErrorMessage.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Email Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(27),
        child: Column(
          children: [
            Image.asset(
              'images/email.png',
              height: 300,
            ),
            const SizedBox(height: 30),
            const Text(
              'Verify your email',
              style: TextStyle(fontFamily: "Gilroy", fontSize: 28),
            ),
            const SizedBox(height: 15),
            Text(
              'A verification email has been sent to \n $email. Please check your email.',
              style: const TextStyle(fontSize: 16, fontFamily: "Gilroy Pro"),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            MyButton(
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                await user?.reload();
                if (user?.emailVerified ?? false) {
                  // If email is verified, navigate to home page
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  // If email is not verified, resend verification email
                  await resendVerificationEmail(context);
                }
              },
              text: 'Continue',
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => resendVerificationEmail(context),
              child: const Text(
                'Resend Email',
                style: TextStyle(
                  color: Color(0xffEC6408),
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xffEC6408),
                  decorationThickness: 3,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
