class CategoryResponseModel {
  final String id;
  final String categoryName;

  CategoryResponseModel({
    required this.id,
    required this.categoryName,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseModel(
      id: json['id']?.toString() ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}
