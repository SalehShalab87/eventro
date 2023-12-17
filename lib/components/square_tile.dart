// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

// google +apple + facebook icons in login and register pages

class SquareTile extends StatefulWidget {
  final Function()? onTap;
  const SquareTile({super.key, required this.ImagePath, required this.onTap});

  // Image path for icons

  final String ImagePath;

  @override
  State<SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff9D9898)),
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300]),
        child: Image.asset(
          widget.ImagePath,
          height: 40,
        ),
      ),
    );
  }
}
