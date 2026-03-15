class SupportMessageModel {
  final String id;
  final String senderName;
  final String senderRole;
  final String content;
  final DateTime createdAt;

  const SupportMessageModel({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  bool get isFromAdmin => senderRole.toLowerCase() == 'admin';

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: (json['id'] ?? '').toString(),
      senderName: (json['senderName'] ?? json['fullName'] ?? 'User').toString(),
      senderRole: (json['senderRole'] ?? json['role'] ?? 'Customer').toString(),
      content: (json['content'] ?? json['message'] ?? '').toString(),
      createdAt:
          DateTime.tryParse(
            (json['createdAt'] ?? json['sentAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}
