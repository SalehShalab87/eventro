import 'package:eventro/components/my_button.dart';
import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [MyButton(onTap: () => Navigator.pop(context), text: 'OK')],
    ),
  );
}
