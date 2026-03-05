import '../entities/booking_entity.dart';
import '../../data/models/booking/booking_create_request.dart';

abstract class IBookingRepository {
  Future<BookingAvailabilityEntity> getAvailability(String courtId, DateTime date);
  Future<BookingEntity> createBooking(BookingCreateRequest request);
  Future<List<BookingEntity>> getMyHistory({
    int page = 1,
    int pageSize = 10,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<BookingEntity> cancelBooking(String bookingId);
}
