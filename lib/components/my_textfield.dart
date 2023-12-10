// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

//your name textfield
class MyNmaeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyNmaeTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: const Color(0xffEC6408),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color:Colors.black54),
          border: InputBorder.none,
          
        ),
      ),
    );
  }
}

// Email Text Field
class MyEmailTextField extends StatelessWidget {
  const MyEmailTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscuretext,
  });

  //variables used in this class

  final controller;
  final String hintText;
  final bool obscuretext;

  // email textFormValidation

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        cursorColor: const Color(0xffEC6408),
        controller: controller,
        obscureText: obscuretext,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color:Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// Password Text Field

class MyPasswordTextField extends StatelessWidget {
  const MyPasswordTextField({
    super.key,
    required this.controller,
    required this.hinttext,
    required this.obscuretext,
  });

  //variables used in this class

  final controller;
  final String hinttext;
  final bool obscuretext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        cursorColor: const Color(0xffEC6408),
        controller: controller,
        obscureText: obscuretext,
        decoration: InputDecoration(
          hintText: hinttext,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// conform Password Text Field
class MyConfirmPasswordTextField extends StatelessWidget {
  const MyConfirmPasswordTextField({
    super.key,
    required this.controller,
    required this.hinttext,
    required this.obscuretext,
  });

  //variables used in this class

  final controller;
  final String hinttext;
  final bool obscuretext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        cursorColor: const Color(0xffEC6408),
        controller: controller,
        obscureText: obscuretext,
        decoration: InputDecoration(
          hintText: hinttext,
          hintStyle: const TextStyle(color:Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}


