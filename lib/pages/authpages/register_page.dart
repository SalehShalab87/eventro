// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:eventro/Services/auth/facebook_signin.dart';
import 'package:eventro/Services/auth/google_signin.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/components/square_tile.dart';
import 'package:eventro/pages/authpages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Register page code
class RegitserPage extends StatefulWidget {
  const RegitserPage({super.key});

  @override
  State<RegitserPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegitserPage> {
  // Text field Editing Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmedPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Dispose controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Sign up User Method
  void SignUserUp() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xffEC6408)),
        );
      },
    );

    try {
      // Check if the password is confirmed
      if (PasswordConfirmed()) {
        // Create user with email, password, and display name
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());

        // Upload user information to Cloud Firestore
        await uploadUserDataToFirestore();

        // Set the display name for the newly created user
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(_nameController.text.trim());

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Pop the loading circle
        Navigator.pop(context);

        // Show message prompting the user to verify their email
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Signup Successful"),
              content: Text(
                "An email verification link has been sent to ${_emailController.text}. Please verify your email before logging in.",
              ),
              actions: [
                MyButton(onTap: () => Navigator.of(context).pop(), text: 'OK')
              ],
            );
          },
        );
      } else {
        // Pop the loading circle
        Navigator.pop(context);
        ShowErrorMassage("Password does not match!");
      }
    } catch (e) {
      // Pop the loading circle
      Navigator.pop(context);

      // Show an error message
      ShowErrorMassage(e.toString());
    }
  }

  bool PasswordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmedPasswordController.text.trim();
  }

  // Show error message method
  void ShowErrorMassage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        );
      },
    );
  }

  // Show Wrong Email Or Password Method
  void ShowErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            MyButton(onTap: () => Navigator.pop(context), text: 'OK'),
          ],
        );
      },
    );
  }

  // Upload user information to Cloud Firestore
  Future<void> uploadUserDataToFirestore() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    String email = FirebaseAuth.instance.currentUser?.email ?? '';

    // Add user data to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': _nameController.text.trim(),
      'email': email,
      'photoURL': 'https://cdn-icons-png.flaticon.com/512/711/711128.png',
      // Add more fields if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                // Logo
                Image.asset(
                  'images/slogo.png',
                  height: 150,
                  width: 150,
                ),

                // Sign Up text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Sign up',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //user name textfield
                MyNameTextField(
                    controller: _nameController, hintText: 'Your Name'),

                // Username textfield
                MyEmailTextField(
                  controller: _emailController,
                  hintText: 'abc@email.com',
                  obscuretext: false,
                ),

                // Password textfield
                MyPasswordTextField(
                  controller: _passwordController,
                  hinttext: "Your Password",
                  obscuretext: true,
                ),

                // Confirm password textfield
                MyConfirmPasswordTextField(
                  controller: _confirmedPasswordController,
                  hinttext: "Confirm Your Password",
                  obscuretext: true,
                ),

                const SizedBox(
                  height: 20,
                ),

                // Sign up button
                MyButton(
                  text: 'Sign up',
                  onTap: SignUserUp,
                ),

                const SizedBox(
                  height: 20,
                ),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                      Text(
                        'Or Continue With',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xff9D9898),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // Google + Apple sign-in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google button
                    SquareTile(
                      onTap: () => GoogleServices().signInWithGoogle(context),
                      ImagePath: 'images/google.png',
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    // Facebook logo
                    SquareTile(
                      onTap: () =>
                          FacebookServices().signInWithFacebook(context),
                      ImagePath: 'images/facebook.png',
                    )
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                // Not a member, register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff9D9898),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }));
                      },
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffEC6408),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
