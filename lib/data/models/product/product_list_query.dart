class ProductListQuery {
  final String? search;
  final String? categoryId;
  final int? page;
  final int? pageSize;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;

  ProductListQuery({
    this.search,
    this.categoryId,
    this.page,
    this.pageSize,
    this.minPrice,
    this.maxPrice,
    this.sort,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (search != null && search!.isNotEmpty) data['search'] = search;
    if (categoryId != null && categoryId!.isNotEmpty) data['categoryId'] = categoryId;
    if (page != null) data['page'] = page;
    if (pageSize != null) data['pageSize'] = pageSize;
    if (minPrice != null) data['minPrice'] = minPrice;
    if (maxPrice != null) data['maxPrice'] = maxPrice;
    if (sort != null && sort!.isNotEmpty) data['sort'] = sort;
    return data;
  }
}
