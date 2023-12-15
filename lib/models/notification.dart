class Notification {
  String notificationId;
  String userId;
  String eventId;
  String content;
  DateTime timestamp;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.eventId,
    required this.content,
    required this.timestamp,
  });
}
