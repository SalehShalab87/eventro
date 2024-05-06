// ignore_for_file: use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerfication extends StatelessWidget {
  const EmailVerfication({super.key});
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
      showErrorMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String email = ModalRoute.of(context)?.settings.arguments as String;
    return SingleChildScrollView(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(27),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'images/email.png',
                height: 300,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Verfiy your email',
                style: TextStyle(fontFamily: "Gilroy", fontSize: 28),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                  style:
                      const TextStyle(fontSize: 16, fontFamily: "Gilroy Pro"),
                  textAlign: TextAlign.center,
                  'a verification email sent to \n $email please check your email'),
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
                  text: 'Continue'),
              const SizedBox(
                height: 20,
              ),
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
      ),
    );
  }
}
