import 'package:equatable/equatable.dart';
import '../../../data/models/booking/booking_create_request.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

/// Load danh sách sân
class LoadCourtsEvent extends BookingEvent {
  const LoadCourtsEvent();
}

/// Load slot availability cho sân theo ngày
class LoadAvailabilityEvent extends BookingEvent {
  final String courtId;
  final DateTime date;
  const LoadAvailabilityEvent({required this.courtId, required this.date});
  @override
  List<Object?> get props => [courtId, date];
}

/// Chọn slot
class SelectSlotEvent extends BookingEvent {
  final int slotIndex;
  const SelectSlotEvent(this.slotIndex);
  @override
  List<Object?> get props => [slotIndex];
}

/// Bỏ chọn tất cả slot
class ClearSlotsEvent extends BookingEvent {
  const ClearSlotsEvent();
}

/// Load dịch vụ bổ sung
class LoadServicesEvent extends BookingEvent {
  const LoadServicesEvent();
}

/// Thay đổi số lượng dịch vụ
class UpdateServiceQuantityEvent extends BookingEvent {
  final String serviceId;
  final int quantity;
  const UpdateServiceQuantityEvent({required this.serviceId, required this.quantity});
  @override
  List<Object?> get props => [serviceId, quantity];
}

/// Tạo booking
class CreateBookingEvent extends BookingEvent {
  final BookingCreateRequest request;
  const CreateBookingEvent(this.request);
  @override
  List<Object?> get props => [request];
}

/// Load lịch sử booking
class LoadMyHistoryEvent extends BookingEvent {
  final int page;
  final int pageSize;
  final String? status;
  const LoadMyHistoryEvent({this.page = 1, this.pageSize = 10, this.status});
  @override
  List<Object?> get props => [page, pageSize, status];
}

/// Hủy booking
class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  const CancelBookingEvent(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}
