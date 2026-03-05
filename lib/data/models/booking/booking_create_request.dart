class BookingCreateRequest {
  final String courtId;
  final DateTime startTime;
  final DateTime endTime;
  final List<BookingServiceItemRequest>? serviceItems;

  BookingCreateRequest({
    required this.courtId,
    required this.startTime,
    required this.endTime,
    this.serviceItems,
  });

  Map<String, dynamic> toJson() {
    // Gửi local time, KHÔNG convert sang UTC
    // Server sẽ xử lý theo timezone của nó
    return {
      'courtId': courtId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      if (serviceItems != null && serviceItems!.isNotEmpty)
        'serviceItems': serviceItems!.map((e) => e.toJson()).toList(),
    };
  }
}

class BookingServiceItemRequest {
  final String serviceId;
  final int quantity;

  BookingServiceItemRequest({
    required this.serviceId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'quantity': quantity,
    };
  }
}
