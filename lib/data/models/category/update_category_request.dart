class UpdateCategoryRequest {
  final String categoryName;

  UpdateCategoryRequest({required this.categoryName});

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
    };
  }
}
