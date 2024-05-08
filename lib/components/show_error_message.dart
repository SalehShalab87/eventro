import 'package:flutter/material.dart';

class ShowErrorMessage extends StatelessWidget {
  final String message;

  const ShowErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    );
  }
}
