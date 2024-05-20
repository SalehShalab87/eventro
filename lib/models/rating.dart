class Rating {
  final String eventId;
  final double rating;

  Rating({required this.eventId, required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'rating': rating,
    };
  }
}
