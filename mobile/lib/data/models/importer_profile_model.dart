import 'user_model.dart';

class ImporterProfileModel {
  final String id;
  final String businessName;
  final String businessType;
  final String? tinNumber;
  final String? businessLicenseNumber;
  final String? description;

  /// Backend: importerProfile.model.js → yearEstablished (Number, nullable)
  final int? yearEstablished;

  /// Backend: importerProfile.model.js → contactPhone (String, nullable)
  final String? contactPhone;

  /// Backend: importerProfile.model.js → contactEmail (String, nullable)
  final String? contactEmail;

  final List<String> serviceAreas;
  final List<String> supportedCategoryIds;
  final String
  verificationStatus; // pending | approved | rejected | suspended | expired
  final String? verificationNotes;
  final double ratingAverage;
  final int ratingCount;
  final int completedOrdersCount;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final UserModel? user;

  ImporterProfileModel({
    required this.id,
    required this.businessName,
    required this.businessType,
    this.tinNumber,
    this.businessLicenseNumber,
    this.description,
    this.yearEstablished,
    this.contactPhone,
    this.contactEmail,
    this.serviceAreas = const [],
    this.supportedCategoryIds = const [],
    required this.verificationStatus,
    this.verificationNotes,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.completedOrdersCount = 0,
    this.verifiedAt,
    this.createdAt,
    this.user,
  });

  bool get isApproved => verificationStatus == 'approved';

  factory ImporterProfileModel.fromJson(
    Map<String, dynamic> json,
  ) => ImporterProfileModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    businessName: (json['businessName'] ?? '').toString(),
    businessType: (json['businessType'] ?? 'individual').toString(),
    tinNumber: json['tinNumber']?.toString(),
    businessLicenseNumber: json['businessLicenseNumber']?.toString(),
    description: json['description']?.toString(),
    yearEstablished: (json['yearEstablished'] as num?)?.toInt(),
    contactPhone: json['contactPhone']?.toString(),
    contactEmail: json['contactEmail']?.toString(),
    serviceAreas: (json['serviceAreas'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    supportedCategoryIds: (json['supportedCategoryIds'] as List? ?? const [])
        .map((e) => e is Map ? (e['_id'] ?? '').toString() : e.toString())
        .toList(),
    verificationStatus: (json['verificationStatus'] ?? 'pending').toString(),
    verificationNotes: json['verificationNotes']?.toString(),
    ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0,
    ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    completedOrdersCount: (json['completedOrdersCount'] as num?)?.toInt() ?? 0,
    verifiedAt: json['verifiedAt'] != null
        ? DateTime.tryParse(json['verifiedAt'].toString())
        : null,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null,
    user: json['user'] is Map<String, dynamic>
        ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
        : null,
  );
}
