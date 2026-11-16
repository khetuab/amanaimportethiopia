// message_model.dart
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final String senderName;
  final String body;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    final s = j['sender'];
    return MessageModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      conversationId: (j['conversation'] ?? '').toString(),
      senderId: (s is Map ? (s['_id'] ?? '') : s ?? '').toString(),
      senderRole: (j['senderRole'] ?? '').toString(),
      senderName: (s is Map ? (s['fullName'] ?? '') : '').toString(),
      body: (j['body'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
