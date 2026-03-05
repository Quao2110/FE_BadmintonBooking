import 'booking_slot_model.dart';

class BookingAvailabilityModel {
  final String courtId;
  final DateTime date;
  final String openTime;
  final String closeTime;
  final int slotMinutes;
  final List<BookingSlotModel> slots;

  BookingAvailabilityModel({
    required this.courtId,
    required this.date,
    required this.openTime,
    required this.closeTime,
    required this.slotMinutes,
    required this.slots,
  });

  factory BookingAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return BookingAvailabilityModel(
      courtId: json['courtId']?.toString() ?? '',
      date: DateTime.parse(json['date']),
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      slotMinutes: json['slotMinutes'] ?? 60,
      slots: (json['slots'] as List?)
              ?.map((e) => BookingSlotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
