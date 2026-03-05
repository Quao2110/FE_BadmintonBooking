class BookingServiceItemModel {
  final String serviceId;
  final String serviceName;
  final int quantity;
  final double priceAtBooking;

  BookingServiceItemModel({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.priceAtBooking,
  });

  double get lineTotal => priceAtBooking * quantity;

  factory BookingServiceItemModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceItemModel(
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName'] ?? '',
      quantity: json['quantity'] ?? 0,
      priceAtBooking: (json['priceAtBooking'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'serviceId': serviceId,
      'quantity': quantity,
    };
  }
}
