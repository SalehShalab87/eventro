// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/Services/auth/facebook_signin.dart';
import 'package:eventro/Services/auth/google_signin.dart';
import 'package:eventro/components/my_button.dart';
import 'package:eventro/components/my_textfield.dart';
import 'package:eventro/components/show_error_message.dart';
import 'package:eventro/components/square_tile.dart';
import 'package:eventro/pages/authpages/forget_password_page.dart';
import 'package:eventro/pages/authpages/register_page.dart';
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
  Map<String, dynamic>? adminCredentials;

  // Checkbox state
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Retrieve admin credentials when the login page is initialized
    getAdminCredentials().then((credentials) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          adminCredentials = credentials;
        });
      }
    });
  }

  Future<Map<String, dynamic>> getAdminCredentials() async {
    try {
      // Get a reference to the admins collection in Firestore
      DocumentSnapshot adminsSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('eventroadmin')
          .get();

      // Check if any admin documents exist
      if (adminsSnapshot.exists) {
        // Extract the admin credentials from the first document
        Map<String, dynamic> adminData =
            adminsSnapshot.data() as Map<String, dynamic>;
        return adminData;
      } else {
        // No admin documents found
        return {};
      }
    } catch (e) {
      // Error retrieving admin credentials
      ShowErrorMessage.showError(context, e.toString());
      return {};
    }
  }

  void SignUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xffEC6408)),
        );
      },
    );

    try {
      // Get user input credentials
      String userEmail = EmailController.text.trim();
      String userPassword = PasswordController.text.trim();

      if (isAdmin) {
        // If isAdmin is true, attempt admin login
        if (adminCredentials != null &&
            adminCredentials!['email'] == userEmail &&
            adminCredentials!['password'] == userPassword) {
          // User is logging in as an admin
          // Perform admin login actions (e.g., navigate to admin dashboard)
          Navigator.pushNamedAndRemoveUntil(
              context, '/admin_dashboard', (_) => false);
        } else {
          Navigator.pop(context);
          // Invalid admin credentials
          ShowErrorMassage("Invalid admin credentials.");
        }
      } else {
        // Perform regular user login with email and password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );

        // Check if email is verified
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          // Email is verified, navigate to the home screen
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        } else {
          // Email is not verified, show error message
          ShowErrorMassage("Email not verified.");
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ShowErrorMassage("Email Or Password Is Incorrect!");
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
                const SizedBox(
                  height: 20,
                ),
                //logo
                Image.asset(
                  'images/slogo.png',
                  height: 150,
                  width: 150,
                ),

                const SizedBox(
                  height: 30,
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
                ),

                // Checkbox for admin login and Forget Password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.black,
                            activeColor: const Color(0xffEC6408),
                            value: isAdmin,
                            onChanged: (value) {
                              setState(() {
                                isAdmin = value!;
                              });
                            },
                          ),
                          const Text('Login as Admin',
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ForgetMyPasswordPage();
                          }));
                        },
                        child: Text(
                          'Forget Password?',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
                        onTap: () => GoogleServices().signInWithGoogle(context),
                        ImagePath: 'images/google.png'),

                    const SizedBox(
                      width: 10,
                    ),

                    //facebook logo
                    SquareTile(
                        onTap: () =>
                            FacebookServices().signInWithFacebook(context),
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
