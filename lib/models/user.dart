import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final String photoUrl;

  User({required this.name, required this.email, required this.photoUrl});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? '',
      photoUrl: data['photoURL'] ?? '',
    );
  }
}
