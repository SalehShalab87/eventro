import 'package:flutter/material.dart';

class Event {
  final String name;
  final String imagePath;
  final String description;
  final String price;

  Event(this.name, this.imagePath, this.description, {required this.price});
}
