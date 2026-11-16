class DisputeEvidence {
  final String key;
  final String url;
  final String? mimeType;
  final String? description;
  DisputeEvidence({
    required this.key,
    required this.url,
    this.mimeType,
    this.description,
  });

  factory DisputeEvidence.fromJson(Map<String, dynamic> j) => DisputeEvidence(
    key: (j['key'] ?? '').toString(),
    url: (j['url'] ?? '').toString(),
    mimeType: j['mimeType']?.toString(),
    description: j['description']?.toString(),
  );
}

class DisputeMessage {
  final String authorRole;
  final String body;
  final DateTime at;
  DisputeMessage({
    required this.authorRole,
    required this.body,
    required this.at,
  });

  factory DisputeMessage.fromJson(Map<String, dynamic> j) => DisputeMessage(
    authorRole: (j['authorRole'] ?? '').toString(),
    body: (j['body'] ?? '').toString(),
    at: DateTime.tryParse((j['at'] ?? '').toString()) ?? DateTime.now(),
  );
}

class DisputeModel {
  final String id;
  final String orderId;
  final String? orderReference;
  final String openedByRole;
  final String reason;
  final String description;
  final String status;
  final List<DisputeEvidence> evidence;
  final List<DisputeMessage> messages;
  final String? resolutionOutcome;
  final double? refundPromisedETB;
  final DateTime? createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    this.orderReference,
    required this.openedByRole,
    required this.reason,
    required this.description,
    required this.status,
    this.evidence = const [],
    this.messages = const [],
    this.resolutionOutcome,
    this.refundPromisedETB,
    this.createdAt,
  });

  bool get isOpen => status == 'open' || status == 'under_review';

  factory DisputeModel.fromJson(Map<String, dynamic> j) {
    String orderId;
    String? orderRef;
    final o = j['order'];
    if (o is Map) {
      orderId = (o['_id'] ?? '').toString();
      orderRef = o['referenceNumber']?.toString();
    } else {
      orderId = (o ?? '').toString();
    }
    final res = j['resolution'];
    return DisputeModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      orderId: orderId,
      orderReference: orderRef,
      openedByRole: (j['openedByRole'] ?? '').toString(),
      reason: (j['reason'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      status: (j['status'] ?? 'open').toString(),
      evidence: (j['evidence'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DisputeEvidence.fromJson)
          .toList(),
      messages: (j['messages'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DisputeMessage.fromJson)
          .toList(),
      resolutionOutcome: res is Map ? res['outcome']?.toString() : null,
      refundPromisedETB: res is Map
          ? (res['refundPromisedETB'] as num?)?.toDouble()
          : null,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString())
          : null,
    );
  }
}
