class PaymentRecordModel {
  final String id;
  final String orderId;
  final String? orderReference;
  final String transactionReference;
  final double amountETB;
  final String paymentChannel;
  final DateTime? paidAt;
  final String? receiptUrl;
  final String status;
  final bool isVerified;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  PaymentRecordModel({
    required this.id,
    required this.orderId,
    this.orderReference,
    required this.transactionReference,
    required this.amountETB,
    required this.paymentChannel,
    this.paidAt,
    this.receiptUrl,
    required this.status,
    this.isVerified = false,
    this.rejectionReason,
    this.reviewedAt,
    this.createdAt,
  });

  factory PaymentRecordModel.fromJson(Map<String, dynamic> j) {
    String? orderRef;
    String orderId;
    final o = j['order'];
    if (o is Map) {
      orderId = (o['_id'] ?? '').toString();
      orderRef = o['referenceNumber']?.toString();
    } else {
      orderId = (o ?? '').toString();
    }
    return PaymentRecordModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      orderId: orderId,
      orderReference: orderRef,
      transactionReference: (j['transactionReference'] ?? '').toString(),
      amountETB: (j['amountETB'] as num?)?.toDouble() ?? 0,
      paymentChannel: (j['paymentChannel'] ?? '').toString(),
      paidAt: j['paidAt'] != null
          ? DateTime.tryParse(j['paidAt'].toString())
          : null,
      receiptUrl: j['receiptUrl']?.toString(),
      status: (j['status'] ?? 'submitted').toString(),
      isVerified: j['isVerified'] == true,
      rejectionReason: j['rejectionReason']?.toString(),
      reviewedAt: j['reviewedAt'] != null
          ? DateTime.tryParse(j['reviewedAt'].toString())
          : null,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString())
          : null,
    );
  }
}
