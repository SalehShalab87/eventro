// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:eventro/Services/auth_service.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/components/square_tile.dart';
import 'package:eventro/pages/forget_password_page.dart';
import 'package:eventro/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Editing Controllers
  final EmailController = TextEditingController();

  final PasswordController = TextEditingController();

  void SignUserIn() async {
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
      // Attempt to sign in with user
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: EmailController.text,
        password: PasswordController.text,
      );

      // Pop the loading circle
      Navigator.pop(context);

      // Check if sign-in is successful
      if (FirebaseAuth.instance.currentUser != null) {
        // Navigate to the home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle the case where the user is not signed in
        // Show an error message or take appropriate action
        ShowErrorMassage("Sign-in failed. User not found.");
      }
    } on FirebaseAuthException catch (e) {
      // Pop the loading circle
      Navigator.pop(context);

      // Show an error message
      ShowErrorMassage(e.message.toString());
    }
  }

  //show Wrong Email
  void ShowErrorMassage(String Massge) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(Massge),
            actions: [
              MyButton(onTap: () => Navigator.pop(context), text: 'OK')
            ],
          );
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
                //logo
                Image.asset(
                  'images/slogo.png',
                  height: 170,
                  width: 170,
                ),

                //Sign in text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Sign in',
                        style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //Email textfield
                MyEmailTextField(
                  controller: EmailController,
                  hintText: 'abc@email.com',
                  obscuretext: false,
                ),

                //password textfield
                MyPasswordTextField(
                  controller: PasswordController,
                  hinttext: "Your Password",
                  obscuretext: true,
                ),

                //forget passsword
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ForgetMyPasswordPage();
                          }));
                        },
                        child: Text(
                          'Foreget Password?',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffEC6408)),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //sgin button
                MyButton(
                  text: 'Sign in',
                  onTap: SignUserIn,
                ),

                const SizedBox(
                  height: 40,
                ),

                //or continue with

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                      Text('Or Continue With',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xff9D9898))),
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                //google + apple sgin in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google button
                    SquareTile(
                        onTap: () => AuthService().signInWithGoogle(context),
                        ImagePath: 'images/google.png'),

                    const SizedBox(
                      width: 10,
                    ),

                    //apple button
                    SquareTile(onTap: () => {}, ImagePath: 'images/apple.png'),

                    const SizedBox(
                      width: 10,
                    ),

                    //facebook logo
                    SquareTile(
                        onTap: () => AuthService().signInWithFacebook(context),
                        ImagePath: 'images/facebook.png')
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                //not a member registr now

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff9D9898)),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const RegitserPage();
                        }));
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xffEC6408)),
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
