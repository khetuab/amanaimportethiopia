class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? parentId;
  final bool isActive;
  final bool isRestricted;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.parentId,
    this.isActive = true,
    this.isRestricted = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
    id: (j['_id'] ?? j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    slug: (j['slug'] ?? '').toString(),
    description: j['description']?.toString(),
    parentId: j['parentId']?.toString(),
    isActive: j['isActive'] != false,
    isRestricted: j['isRestricted'] == true,
  );
}
