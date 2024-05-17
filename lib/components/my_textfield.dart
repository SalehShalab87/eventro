// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//your name textfield
class MyNameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyNameTextField({
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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        keyboardType: TextInputType.name,
        controller: controller,
        obscureText: obscureText,
        cursorColor: const Color(0xffEC6408),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
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
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xffEC6408),
        controller: controller,
        obscureText: obscuretext,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// Password Text Field

class MyPasswordTextField extends StatefulWidget {
  const MyPasswordTextField({
    super.key,
    required this.controller,
    required this.hinttext,
  });

  final TextEditingController controller;
  final String hinttext;

  @override
  _MyPasswordTextFieldState createState() => _MyPasswordTextFieldState();
}

class _MyPasswordTextFieldState extends State<MyPasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        cursorColor: const Color(0xffEC6408),
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: widget.hinttext,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: IconButton(
            alignment: Alignment.centerRight,
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }
}

// Confirm Password Text Field

class MyConfirmPasswordTextField extends StatefulWidget {
  const MyConfirmPasswordTextField({
    super.key,
    required this.controller,
    required this.hinttext,
  });

  final TextEditingController controller;
  final String hinttext;

  @override
  _MyConfirmPasswordTextFieldState createState() =>
      _MyConfirmPasswordTextFieldState();
}

class _MyConfirmPasswordTextFieldState
    extends State<MyConfirmPasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        cursorColor: const Color(0xffEC6408),
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: widget.hinttext,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: IconButton(
            alignment: Alignment.centerRight,
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }
}

//sarch text field textfield
class MySearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Function(String) onChanged;

  const MySearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: const Color(0xffEC6408),
        onChanged: onChanged,
        decoration: InputDecoration(
          suffixIcon: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.tune),
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.search),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

//Input Text Form field

class InputFiled extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final List<TextInputFormatter>? inputFormatter;
  final TextInputType type;
  final FormFieldValidator<String>? validator; // Add validator

  const InputFiled({
    super.key,
    required this.controller,
    required this.hintText,
    this.inputFormatter,
    required this.type,
    required this.validator, // Receive validator
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        // Change TextField to TextFormField
        keyboardType: type,
        cursorColor: const Color(0xffEC6408),
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
        validator: validator, // Set validator
      ),
    );
  }
}

class DateTimeInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final VoidCallback onPressed;
  const DateTimeInput(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: TextFormField(
        cursorColor: const Color(0xffEC6408),
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: IconButton(icon: Icon(icon), onPressed: onPressed),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
        readOnly: true,
      ),
    );
  }
}
