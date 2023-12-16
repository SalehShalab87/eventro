class Event {
  final String eventId;
  final String imageUrl;
  final String location;
  final String title;
  final String price;
  final String description;
  final DateTime? dateTime;

  Event({
    required this.eventId,
    required this.imageUrl,
    required this.location,
    required this.title,
    required this.dateTime,
    required this.price,
    required this.description,
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
    };
  }
}
