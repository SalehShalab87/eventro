import 'package:flutter/material.dart';

void showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: Color(0xffEC6408)),
    ),
    barrierDismissible: false,
  );
}
