import 'package:flutter/material.dart';

class AdminNotifcation extends StatefulWidget {
  const AdminNotifcation({super.key});

  @override
  State<AdminNotifcation> createState() => _AdminNotifcationState();
}

class _AdminNotifcationState extends State<AdminNotifcation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Notfication Page')),
    );
  }
}
