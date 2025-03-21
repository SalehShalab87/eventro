import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  //var needed in this tile
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const MyListTile(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black54,
        ),
        onTap: onTap,
        title: Text(text,
            style:
                const TextStyle(fontFamily: "Gilroy", color: Colors.black54)),
      ),
    );
  }
}
