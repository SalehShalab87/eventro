class Reminder {
  String reminderId;
  String userId;
  String eventId;
  DateTime reminderTime;
  String status;

  Reminder({
    required this.reminderId,
    required this.userId,
    required this.eventId,
    required this.reminderTime,
    required this.status,
  });
}
