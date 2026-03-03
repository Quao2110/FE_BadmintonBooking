class ServiceEntity {
  final String id;
  final String serviceName;
  final double price;
  final String unit;
  final int stockQuantity;
  final bool isActive;

  ServiceEntity({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.isActive,
  });
}
