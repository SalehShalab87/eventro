class Event {
  final String eventId;
  final String imageUrl;
  //final String location;
  final String title;
  final String price;
  final String description;
  //final String date;
  //final String time;

  Event({
    required this.eventId,
    required this.imageUrl,
    //required this.location,
    required this.title,
    //required this.date,
    //required this.time,
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
      // Add other attributes as needed
    };
  }
}
