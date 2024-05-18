import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String imageUrl;
  final String location;
  final String title;
  final String price;
  final String description;
  final DateTime? dateTime;
  final String eventType; // New field
  int maxCapacity;
  int currentAttendees;
  String approvalStatus;
  final double latitude;
  final double longitude;

  Event({
    required this.eventId,
    required this.imageUrl,
    required this.location,
    required this.title,
    required this.dateTime,
    required this.price,
    required this.description,
    required this.eventType,
    required this.maxCapacity,
    required this.currentAttendees,
    required this.approvalStatus,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'imageUrl': imageUrl,
      'title': title,
      'price': price,
      'description': description,
      'location': location,
      'dateTime': dateTime,
      'eventType': eventType,
      'maxCapacity': maxCapacity,
      'currentAttendees': currentAttendees,
      'status': approvalStatus,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Event.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Event(
      eventId: snapshot.id,
      imageUrl: data['imageUrl'],
      location: data['location'] ?? '',
      title: data['title'],
      dateTime: data['datetime'] != null
          ? (data['datetime'] as Timestamp).toDate()
          : null,
      price: data['price'] ?? '',
      description: data['description'] ?? '',
      eventType: data['eventType'] ?? '',
      maxCapacity: data['maxCapacity'] ??
          0, // Provide a default value if it's not available
      currentAttendees: data['currentAttendees'] ??
          0, // Provide a default value if it's not available
      approvalStatus: data['status'] ?? '',
      latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['long'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
