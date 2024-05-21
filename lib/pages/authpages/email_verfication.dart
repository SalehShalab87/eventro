// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool _isEmailVerified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isEmailVerified = user.emailVerified;
      });
    }
  }

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
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? '';

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
                setState(() {
                  _isLoading = true;
                });
                await _checkEmailVerification();
                if (_isEmailVerified) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ShowErrorMessage.showError(
                      context, 'Email not verified. Please verify your email.');
                }
                setState(() {
                  _isLoading = false;
                });
              },
              text: _isLoading ? 'Checking...' : 'Continue',
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
