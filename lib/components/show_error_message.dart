import 'package:flutter/material.dart';

class ShowErrorMessage {
  static final ShowErrorMessage _instance = ShowErrorMessage._internal();

  factory ShowErrorMessage() {
    return _instance;
  }

  ShowErrorMessage._internal();

  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
