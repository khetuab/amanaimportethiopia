class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final int? communicationRating;
  final int? deliveryRating;
  final int? qualityRating;
  final String reviewerName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    this.communicationRating,
    this.deliveryRating,
    this.qualityRating,
    required this.reviewerName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final r = j['reviewer'];
    return ReviewModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: j['comment']?.toString(),
      communicationRating: (j['communicationRating'] as num?)?.toInt(),
      deliveryRating: (j['deliveryRating'] as num?)?.toInt(),
      qualityRating: (j['qualityRating'] as num?)?.toInt(),
      reviewerName: r is Map
          ? (r['fullName'] ?? 'Anonymous').toString()
          : 'Anonymous',
      createdAt:
          DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
