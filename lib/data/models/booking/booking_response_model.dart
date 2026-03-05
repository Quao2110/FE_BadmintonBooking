import 'booking_service_item_model.dart';

class BookingResponseModel {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final bool isPaid;
  final DateTime? createdAt;
  final List<BookingServiceItemModel> services;

  BookingResponseModel({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.isPaid,
    this.createdAt,
    required this.services,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      courtId: json['courtId']?.toString() ?? '',
      courtName: json['courtName'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      isPaid: json['isPaid'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      services: (json['services'] as List?)
              ?.map((e) => BookingServiceItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
