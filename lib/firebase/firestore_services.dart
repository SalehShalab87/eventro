import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Create an object for the firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collection for the events
  CollectionReference events =
      FirebaseFirestore.instance.collection('eventsCollection');
}
