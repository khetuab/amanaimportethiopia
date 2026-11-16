// conversation_model.dart
class ConversationModel {
  final String id;
  final String orderId;
  final String? orderReference;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int buyerUnreadCount;
  final int importerUnreadCount;

  ConversationModel({
    required this.id,
    required this.orderId,
    this.orderReference,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.buyerUnreadCount = 0,
    this.importerUnreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) {
    String orderId;
    String? orderRef;
    final o = j['order'];
    if (o is Map) {
      orderId = (o['_id'] ?? '').toString();
      orderRef = o['referenceNumber']?.toString();
    } else {
      orderId = (o ?? '').toString();
    }
    return ConversationModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      orderId: orderId,
      orderReference: orderRef,
      lastMessagePreview: j['lastMessagePreview']?.toString(),
      lastMessageAt: j['lastMessageAt'] != null
          ? DateTime.tryParse(j['lastMessageAt'].toString())
          : null,
      buyerUnreadCount: (j['buyerUnreadCount'] as num?)?.toInt() ?? 0,
      importerUnreadCount: (j['importerUnreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
