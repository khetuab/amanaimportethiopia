class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
        data: (j['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        isRead: j['readAt'] != null,
        createdAt:
            DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
            DateTime.now(),
      );
}
