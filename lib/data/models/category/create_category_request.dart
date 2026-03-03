class CreateCategoryRequest {
  final String categoryName;

  CreateCategoryRequest({required this.categoryName});

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
    };
  }
}
