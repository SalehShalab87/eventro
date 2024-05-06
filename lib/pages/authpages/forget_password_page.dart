// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//this is the forget password page after tap on "forget password"

class ForgetMyPasswordPage extends StatefulWidget {
  const ForgetMyPasswordPage({super.key});

  @override
  State<ForgetMyPasswordPage> createState() => _ForgetMyPasswordPageState();
}

class _ForgetMyPasswordPageState extends State<ForgetMyPasswordPage> {
  final EmailController = TextEditingController();

  @override
  void dispose() {
    EmailController.dispose();
    super.dispose();
  }

  // Password Rest Method
  Future PasswordRest() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xffEC6408)),
        );
      },
    );
    //try sign in with user
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: EmailController.text.trim());
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                'The password link sent! check your email',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              actions: [
                MyButton(onTap: () => Navigator.pop(context), text: 'OK')
              ],
            );
          });
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context); // Close loading dialog
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(error.message.toString()),
              actions: [
                MyButton(onTap: () => Navigator.pop(context), text: 'OK')
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Image.asset(
              'images/password.png',
              height: 300,
            ),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'Please enter your email address to request a password reset',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Gilroy', fontSize: 16),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            //Email textfield
            MyEmailTextField(
              controller: EmailController,
              hintText: 'abc@email.com',
              obscuretext: false,
            ),
            const SizedBox(
              height: 30,
            ),
            MyButton(
              text: 'Send',
              onTap: PasswordRest,
            ),
          ],
        ));
  }
}
