class ItemizedCost {
  final String label;
  final double amountETB;
  final String? note;

  ItemizedCost({required this.label, required this.amountETB, this.note});

  factory ItemizedCost.fromJson(Map<String, dynamic> j) => ItemizedCost(
    label: (j['label'] ?? '').toString(),
    amountETB: (j['amountETB'] as num?)?.toDouble() ?? 0,
    note: j['note']?.toString(),
  );
}

class QuotationModel {
  final String id;
  final String referenceNumber;
  final String requestId;
  final String importerProfileId;
  final String? importerBusinessName;
  final double? importerRating;
  final int importerRatingCount;
  final double totalPriceETB;
  final List<ItemizedCost> itemizedCosts;
  final bool isEstimateFinal;
  final String? exclusions;
  final String productCondition;
  final String? specifications;
  final String? warrantyOffered;
  final String? returnPolicy;
  final int estimatedDeliveryDays;
  final DateTime? quotationValidUntil;
  final String? notes;
  final String status;
  final DateTime? acceptedAt;
  final Map<String, dynamic>? contact;

  QuotationModel({
    required this.id,
    required this.referenceNumber,
    required this.requestId,
    required this.importerProfileId,
    this.importerBusinessName,
    this.importerRating,
    this.importerRatingCount = 0,
    required this.totalPriceETB,
    this.itemizedCosts = const [],
    this.isEstimateFinal = false,
    this.exclusions,
    required this.productCondition,
    this.specifications,
    this.warrantyOffered,
    this.returnPolicy,
    required this.estimatedDeliveryDays,
    this.quotationValidUntil,
    this.notes,
    required this.status,
    this.acceptedAt,
    this.contact,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> j) {
    final imp = j['importerProfile'];
    final req = j['request'];
    final reqId = req is Map
        ? (req['_id'] ?? req['id'] ?? '').toString()
        : (req ?? '').toString();
    String? bizName;
    double? rating;
    int ratingCount = 0;
    if (imp is Map) {
      bizName = imp['businessName']?.toString();
      rating = (imp['ratingAverage'] as num?)?.toDouble();
      ratingCount = (imp['ratingCount'] as num?)?.toInt() ?? 0;
    }
    return QuotationModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      referenceNumber: (j['referenceNumber'] ?? '').toString(),
      requestId: reqId,
      importerProfileId: (imp is Map ? (imp['_id'] ?? '') : imp ?? '')
          .toString(),
      importerBusinessName: bizName,
      importerRating: rating,
      importerRatingCount: ratingCount,
      totalPriceETB: (j['totalPriceETB'] as num?)?.toDouble() ?? 0,
      itemizedCosts: (j['itemizedCosts'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ItemizedCost.fromJson)
          .toList(),
      isEstimateFinal: j['isEstimateFinal'] == true,
      exclusions: j['exclusions']?.toString(),
      productCondition: (j['productCondition'] ?? 'new').toString(),
      specifications: j['specifications']?.toString(),
      warrantyOffered: j['warrantyOffered']?.toString(),
      returnPolicy: j['returnPolicy']?.toString(),
      estimatedDeliveryDays: (j['estimatedDeliveryDays'] as num?)?.toInt() ?? 0,
      quotationValidUntil: j['quotationValidUntil'] != null
          ? DateTime.tryParse(j['quotationValidUntil'].toString())
          : null,
      notes: j['notes']?.toString(),
      status: (j['status'] ?? 'submitted').toString(),
      acceptedAt: j['acceptedAt'] != null
          ? DateTime.tryParse(j['acceptedAt'].toString())
          : null,
      contact: j['contact'] is Map<String, dynamic> ? j['contact'] : null,
    );
  }
}
