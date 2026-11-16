class OrderItemizedCost {
  final String label;
  final double amountETB;
  final String? note;
  OrderItemizedCost({required this.label, required this.amountETB, this.note});

  factory OrderItemizedCost.fromJson(Map<String, dynamic> j) =>
      OrderItemizedCost(
        label: (j['label'] ?? '').toString(),
        amountETB: (j['amountETB'] as num?)?.toDouble() ?? 0,
        note: j['note']?.toString(),
      );
}

class OrderSnapshot {
  final String requestReferenceNumber;
  final String quotationReferenceNumber;
  final String title;
  final int quantity;
  final String unitOfMeasurement;
  final String deliveryCity;
  final String? deliveryAddress;
  final String productCondition;
  final String? specifications;
  final String? warrantyOffered;
  final String? returnPolicy;
  final int estimatedDeliveryDays;
  final bool isEstimateFinal;
  final String? exclusions;
  final List<OrderItemizedCost> itemizedCosts;
  final String importerBusinessName;
  final String? imageUrl;


  OrderSnapshot({
    required this.requestReferenceNumber,
    required this.quotationReferenceNumber,
    required this.title,
    required this.quantity,
    required this.unitOfMeasurement,
    required this.deliveryCity,
    this.deliveryAddress,
    this.imageUrl,
    required this.productCondition,
    this.specifications,
    this.warrantyOffered,
    this.returnPolicy,
    required this.estimatedDeliveryDays,
    this.isEstimateFinal = false,
    this.exclusions,
    this.itemizedCosts = const [],
    required this.importerBusinessName,
  });

  factory OrderSnapshot.fromJson(Map<String, dynamic> j) => OrderSnapshot(
    requestReferenceNumber: (j['requestReferenceNumber'] ?? '').toString(),
    quotationReferenceNumber: (j['quotationReferenceNumber'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    imageUrl: j['imageUrl']?.toString(),
    quantity: (j['quantity'] as num?)?.toInt() ?? 1,
    unitOfMeasurement: (j['unitOfMeasurement'] ?? 'piece').toString(),
    deliveryCity: (j['deliveryCity'] ?? '').toString(),
    deliveryAddress: j['deliveryAddress']?.toString(),
    productCondition: (j['productCondition'] ?? 'new').toString(),
    specifications: j['specifications']?.toString(),
    warrantyOffered: j['warrantyOffered']?.toString(),
    returnPolicy: j['returnPolicy']?.toString(),
    estimatedDeliveryDays: (j['estimatedDeliveryDays'] as num?)?.toInt() ?? 0,
    isEstimateFinal: j['isEstimateFinal'] == true,
    exclusions: j['exclusions']?.toString(),
    itemizedCosts: (j['itemizedCosts'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItemizedCost.fromJson)
        .toList(),
    importerBusinessName: (j['importerBusinessName'] ?? '').toString(),
  );
}

class OrderStatusEvent {
  final String? from;
  final String to;
  final String? actorRole;
  final String? note;
  final DateTime at;

  OrderStatusEvent({
    required this.from,
    required this.to,
    this.actorRole,
    this.note,
    required this.at,
  });

  factory OrderStatusEvent.fromJson(Map<String, dynamic> j) => OrderStatusEvent(
    from: j['from']?.toString(),
    to: (j['to'] ?? '').toString(),
    actorRole: j['actorRole']?.toString(),
    note: j['note']?.toString(),
    at:
        DateTime.tryParse((j['at'] ?? j['createdAt'] ?? '').toString()) ??
        DateTime.now(),
  );
}

class Counterparty {
  final String role;
  final String? businessName;
  final String? fullName;
  final String? email;
  final String? phone;

  Counterparty({
    required this.role,
    this.businessName,
    this.fullName,
    this.email,
    this.phone,
  });

  factory Counterparty.fromJson(Map<String, dynamic> j) => Counterparty(
    role: (j['role'] ?? '').toString(),
    businessName: j['businessName']?.toString(),
    fullName: j['fullName']?.toString(),
    email: j['email']?.toString(),
    phone: j['phone']?.toString(),
  );
}

class OrderModel {
  final String id;
  final String referenceNumber;
  final String buyerId;
  final String importerUserId;
  final String importerProfileId;
  final String requestId;
  final String quotationId;
  final OrderSnapshot snapshot;
  final double totalPriceETB;
  final double platformFeeETB;
  final String platformFeePayer;
  final String? commissionRuleVersion;
  final String status;
  final List<OrderStatusEvent> statusHistory;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final Counterparty? counterparty;

  OrderModel({
    required this.id,
    required this.referenceNumber,
    required this.buyerId,
    required this.importerUserId,
    required this.importerProfileId,
    required this.requestId,
    required this.quotationId,
    required this.snapshot,
    required this.totalPriceETB,
    required this.platformFeeETB,
    required this.platformFeePayer,
    this.commissionRuleVersion,
    required this.status,
    this.statusHistory = const [],
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.counterparty,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: (j['_id'] ?? j['id'] ?? '').toString(),
    referenceNumber: (j['referenceNumber'] ?? '').toString(),
    buyerId: (j['buyer'] ?? '').toString(),
    importerUserId: (j['importerUser'] ?? '').toString(),
    importerProfileId: (j['importerProfile'] ?? '').toString(),
    requestId: (j['request'] ?? '').toString(),
    quotationId: (j['quotation'] ?? '').toString(),
    snapshot: OrderSnapshot.fromJson(
      (j['snapshot'] as Map<String, dynamic>?) ?? const {},
    ),
    totalPriceETB: (j['totalPriceETB'] as num?)?.toDouble() ?? 0,
    platformFeeETB: (j['platformFeeETB'] as num?)?.toDouble() ?? 0,
    platformFeePayer: (j['platformFeePayer'] ?? 'buyer').toString(),
    commissionRuleVersion: j['commissionRuleVersion']?.toString(),
    status: (j['status'] ?? 'awaiting_payment_confirmation').toString(),
    statusHistory: (j['statusHistory'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(OrderStatusEvent.fromJson)
        .toList(),
    acceptedAt: j['acceptedAt'] != null
        ? DateTime.tryParse(j['acceptedAt'].toString())
        : null,
    completedAt: j['completedAt'] != null
        ? DateTime.tryParse(j['completedAt'].toString())
        : null,
    cancelledAt: j['cancelledAt'] != null
        ? DateTime.tryParse(j['cancelledAt'].toString())
        : null,
    createdAt: j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'].toString())
        : null,
    counterparty: j['counterparty'] is Map<String, dynamic>
        ? Counterparty.fromJson(j['counterparty'])
        : null,
  );
}
