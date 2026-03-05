class BookingSlotModel {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  BookingSlotModel({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}
