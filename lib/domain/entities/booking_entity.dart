class BookingSlotEntity {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  BookingSlotEntity({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  String get timeLabel {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }
}

class BookingAvailabilityEntity {
  final String courtId;
  final DateTime date;
  final String openTime;
  final String closeTime;
  final int slotMinutes;
  final List<BookingSlotEntity> slots;

  BookingAvailabilityEntity({
    required this.courtId,
    required this.date,
    required this.openTime,
    required this.closeTime,
    required this.slotMinutes,
    required this.slots,
  });
}

class BookingServiceItemEntity {
  final String serviceId;
  final String serviceName;
  final int quantity;
  final double priceAtBooking;

  BookingServiceItemEntity({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.priceAtBooking,
  });

  double get lineTotal => priceAtBooking * quantity;
}

class BookingEntity {
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
  final List<BookingServiceItemEntity> services;

  BookingEntity({
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

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String get timeLabel {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }
}
