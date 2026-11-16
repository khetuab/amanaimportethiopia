class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // buyer | importer | admin
  final String status;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String preferredLanguage; // en | am
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.preferredLanguage = 'en',
    this.createdAt,
  });

  bool get isBuyer => role == 'buyer';
  bool get isImporter => role == 'importer';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: (j['id'] ?? j['_id'] ?? '').toString(),
    fullName: (j['fullName'] ?? '').toString(),
    email: (j['email'] ?? '').toString(),
    phone: (j['phone'] ?? '').toString(),
    role: (j['role'] ?? 'buyer').toString(),
    status: (j['status'] ?? 'active').toString(),
    isEmailVerified: j['isEmailVerified'] == true,
    isPhoneVerified: j['isPhoneVerified'] == true,
    preferredLanguage: (j['preferredLanguage'] ?? 'en').toString(),
    createdAt: j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'role': role,
    'status': status,
    'isEmailVerified': isEmailVerified,
    'isPhoneVerified': isPhoneVerified,
    'preferredLanguage': preferredLanguage,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
