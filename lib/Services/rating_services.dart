import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventro/models/rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitEventRating(Rating rating) async {
    final eventsRef = _firestore.collection('eventsCollection');
    final eventDoc = await eventsRef.doc(rating.eventId).get();

    if (!eventDoc.exists) {
      return; // Exit if the document does not exist
    }

    var eventData = eventDoc.data();
    if (eventData == null) {
      return; // Exit if data is null
    }

    try {
      int ratingsCount = eventData['ratingsCount'] as int? ?? 0;
      double totalRating = (eventData['totalRating'] as num? ?? 0.0).toDouble();

      // Update total ratings and count
      totalRating += rating.rating;
      ratingsCount++;

      // Calculate new average rating
      double averageRating = totalRating / ratingsCount;

      // Update the event document
      await eventsRef.doc(rating.eventId).update({
        'totalRating': totalRating,
        'ratingsCount': ratingsCount,
        'averageRating': averageRating,
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
