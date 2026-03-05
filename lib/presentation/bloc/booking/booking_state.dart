
import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../domain/entities/court_entity.dart';
import '../../../domain/entities/service_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

/// State chính cho màn hình booking
class BookingDataLoaded extends BookingState {
  final List<CourtEntity> courts;
  final CourtEntity? selectedCourt;
  final DateTime selectedDate;
  final BookingAvailabilityEntity? availability;
  final Set<int> selectedSlotIndices;
  final List<ServiceEntity> services;
  final Map<String, int> serviceQuantities;
  final bool isLoadingAvailability;
  final bool isCreating;
  final String? error;

  const BookingDataLoaded({
    required this.courts,
    this.selectedCourt,
    required this.selectedDate,
    this.availability,
    this.selectedSlotIndices = const {},
    this.services = const [],
    this.serviceQuantities = const {},
    this.isLoadingAvailability = false,
    this.isCreating = false,
    this.error,
  });

  /// Tính tổng giá
  double get totalPrice {
    if (availability == null || selectedSlotIndices.isEmpty) return 0;

    // Giá sân: 120.000 VNĐ / giờ (từ config)
    const courtHourlyRate = 120000.0;
    final slotCount = selectedSlotIndices.length;
    final slotHours = availability!.slotMinutes / 60.0;
    final courtPrice = slotCount * slotHours * courtHourlyRate;

    // Giá dịch vụ
    double servicePrice = 0;
    for (final entry in serviceQuantities.entries) {
      final service = services.firstWhere(
            (s) => s.id == entry.key,
        orElse: () => services.first,
      );
      if (entry.value > 0) {
        servicePrice += service.price * entry.value;
      }
    }

    return courtPrice + servicePrice;
  }

  /// Kiểm tra có thể booking hay không
  bool get canBook =>
      selectedCourt != null &&
          selectedSlotIndices.isNotEmpty &&
          !isCreating;

  /// Lấy thời gian bắt đầu và kết thúc từ các slot đã chọn
  DateTime? get selectedStartTime {
    if (availability == null || selectedSlotIndices.isEmpty) return null;
    final sortedIndices = selectedSlotIndices.toList()..sort();
    return availability!.slots[sortedIndices.first].startTime;
  }

  DateTime? get selectedEndTime {
    if (availability == null || selectedSlotIndices.isEmpty) return null;
    final sortedIndices = selectedSlotIndices.toList()..sort();
    return availability!.slots[sortedIndices.last].endTime;
  }

  BookingDataLoaded copyWith({
    List<CourtEntity>? courts,
    CourtEntity? selectedCourt,
    bool clearSelectedCourt = false,
    DateTime? selectedDate,
    BookingAvailabilityEntity? availability,
    bool clearAvailability = false,
    Set<int>? selectedSlotIndices,
    List<ServiceEntity>? services,
    Map<String, int>? serviceQuantities,
    bool? isLoadingAvailability,
    bool? isCreating,
    String? error,
    bool clearError = false,
  }) {
    return BookingDataLoaded(
      courts: courts ?? this.courts,
      selectedCourt: clearSelectedCourt ? null : (selectedCourt ?? this.selectedCourt),
      selectedDate: selectedDate ?? this.selectedDate,
      availability: clearAvailability ? null : (availability ?? this.availability),
      selectedSlotIndices: selectedSlotIndices ?? this.selectedSlotIndices,
      services: services ?? this.services,
      serviceQuantities: serviceQuantities ?? this.serviceQuantities,
      isLoadingAvailability: isLoadingAvailability ?? this.isLoadingAvailability,
      isCreating: isCreating ?? this.isCreating,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    courts,
    selectedCourt,
    selectedDate,
    availability,
    selectedSlotIndices,
    services,
    serviceQuantities,
    isLoadingAvailability,
    isCreating,
    error,
  ];
}

/// Booking thành công
class BookingCreated extends BookingState {
  final BookingEntity booking;
  const BookingCreated(this.booking);
  @override
  List<Object?> get props => [booking];
}

/// State cho màn hình lịch sử
class BookingHistoryLoaded extends BookingState {
  final List<BookingEntity> bookings;
  final bool isLoading;
  const BookingHistoryLoaded({required this.bookings, this.isLoading = false});
  @override
  List<Object?> get props => [bookings, isLoading];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object?> get props => [message];
}