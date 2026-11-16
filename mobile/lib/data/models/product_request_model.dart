class RequestAttachment {
  const RequestAttachment({
    required this.url,
    this.key,
    this.mimeType,
    this.size,
    this.kind,
    this.originalName,
  });

  final String url;
  final String? key; // Cloudinary public_id
  final String? mimeType;
  final int? size;
  final String? kind;
  final String? originalName;

  bool get isImage => (mimeType ?? 'image/').startsWith('image/');

  factory RequestAttachment.fromJson(Map<String, dynamic> j) => RequestAttachment(
    url: (j['url'] ?? '').toString(),
    key: j['key']?.toString(),
    mimeType: j['mimeType']?.toString(),
    size: (j['size'] as num?)?.toInt(),
    kind: j['kind']?.toString(),
    originalName: j['originalName']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'url': url,
    if (key != null) 'key': key,
    if (mimeType != null) 'mimeType': mimeType,
    if (size != null) 'size': size,
    if (kind != null) 'kind': kind,
    if (originalName != null) 'originalName': originalName,
  };
}

class RequestStatusEvent {
  const RequestStatusEvent({this.from, required this.to, this.actorRole, this.note, this.at});

  final String? from;
  final String to;
  final String? actorRole;
  final String? note;
  final DateTime? at;

  factory RequestStatusEvent.fromJson(Map<String, dynamic> j) => RequestStatusEvent(
    from: j['from']?.toString(),
    to: (j['to'] ?? '').toString(),
    actorRole: j['actorRole']?.toString(),
    note: j['note']?.toString(),
    at: j['at'] != null ? DateTime.tryParse(j['at'].toString()) : null,
  );
}

class ProductRequestModel {
  final String id;
  final String referenceNumber;
  final String title;
  final String description;
  final String categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? brand;
  final String? model;
  final String? referenceUrl;
  final String? specifications;
  final int quantity;
  final String unitOfMeasurement;
  final double? budgetMinETB;
  final double? budgetMaxETB;
  final String deliveryCity;
  final String? deliveryAddress;
  final DateTime? requiredDeliveryDate;
  final bool warrantyRequired;
  final String? warrantyDetails;
  final String? qualityRequirements;
  final String? additionalInstructions;
  final String status;
  final DateTime? expiresAt;
  final DateTime? publishedAt;
  final int quotationsCount;
  final DateTime? createdAt;
  final List<RequestAttachment> attachments;
  final List<RequestStatusEvent> statusHistory;

  ProductRequestModel({
    required this.id,
    required this.referenceNumber,
    required this.title,
    required this.description,
    required this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.brand,
    this.model,
    this.referenceUrl,
    this.specifications,
    required this.quantity,
    this.unitOfMeasurement = 'piece',
    this.budgetMinETB,
    this.budgetMaxETB,
    required this.deliveryCity,
    this.deliveryAddress,
    this.requiredDeliveryDate,
    this.warrantyRequired = false,
    this.warrantyDetails,
    this.qualityRequirements,
    this.additionalInstructions,
    required this.status,
    this.expiresAt,
    this.publishedAt,
    this.quotationsCount = 0,
    this.createdAt,
    this.attachments = const [],
    this.statusHistory = const [],
  });

  /// Uploaded images first; falls back to a reference link if it is http(s).
  List<String> get imageUrls {
    final uploaded = attachments
        .where((a) => a.isImage && a.url.startsWith('http'))
        .map((a) => a.url)
        .toList();
    if (uploaded.isNotEmpty) return uploaded;
    final ref = referenceUrl;
    if (ref != null && ref.startsWith('http')) return [ref];
    return const [];
  }

  String? get primaryImageUrl => imageUrls.isEmpty ? null : imageUrls.first;

  factory ProductRequestModel.fromJson(Map<String, dynamic> j) {
    String? catId;
    String? catName;
    final cat = j['category'];
    if (cat is Map) {
      catId = (cat['_id'] ?? '').toString();
      catName = cat['name']?.toString();
    } else if (cat != null) {
      catId = cat.toString();
    }

    List<T> parseList<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
        raw is List
            ? raw
            .whereType<Map>()
            .map((e) => f(Map<String, dynamic>.from(e)))
            .toList()
            : <T>[];

    return ProductRequestModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      referenceNumber: (j['referenceNumber'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      categoryId: catId ?? '',
      categoryName: catName,
      subcategoryId: j['subcategory']?.toString(),
      brand: j['brand']?.toString(),
      model: j['model']?.toString(),
      referenceUrl: j['referenceUrl']?.toString(),
      specifications: j['specifications']?.toString(),
      quantity: (j['quantity'] as num?)?.toInt() ?? 1,
      unitOfMeasurement: (j['unitOfMeasurement'] ?? 'piece').toString(),
      budgetMinETB: (j['budgetMinETB'] as num?)?.toDouble(),
      budgetMaxETB: (j['budgetMaxETB'] as num?)?.toDouble(),
      deliveryCity: (j['deliveryCity'] ?? '').toString(),
      deliveryAddress: j['deliveryAddress']?.toString(),
      requiredDeliveryDate: j['requiredDeliveryDate'] != null
          ? DateTime.tryParse(j['requiredDeliveryDate'].toString())
          : null,
      warrantyRequired: j['warrantyRequired'] == true,
      warrantyDetails: j['warrantyDetails']?.toString(),
      qualityRequirements: j['qualityRequirements']?.toString(),
      additionalInstructions: j['additionalInstructions']?.toString(),
      status: (j['status'] ?? 'draft').toString(),
      expiresAt: j['expiresAt'] != null
          ? DateTime.tryParse(j['expiresAt'].toString())
          : null,
      publishedAt: j['publishedAt'] != null
          ? DateTime.tryParse(j['publishedAt'].toString())
          : null,
      quotationsCount: (j['quotationsCount'] as num?)?.toInt() ?? 0,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString())
          : null,
      attachments: parseList(j['attachments'], RequestAttachment.fromJson),
      statusHistory: parseList(j['statusHistory'], RequestStatusEvent.fromJson),
    );
  }
}