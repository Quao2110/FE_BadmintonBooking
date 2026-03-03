class ServiceResponseModel {
  final String id;
  final String serviceName;
  final double price;
  final String unit;
  final int stockQuantity;
  final bool isActive;

  ServiceResponseModel({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.isActive,
  });

  factory ServiceResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceResponseModel(
      id: json['id']?.toString() ?? '',
      serviceName: json['serviceName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}
