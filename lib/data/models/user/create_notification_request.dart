class CreateNotificationRequest {
  final String userId;
  final String title;
  final String message;
  final String type;

  CreateNotificationRequest({
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
    };
  }
}
