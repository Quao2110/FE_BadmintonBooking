import '../datasources/booking_api_service.dart';
import '../models/booking/booking_availability_model.dart';
import '../models/booking/booking_response_model.dart';
import '../models/booking/booking_create_request.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/i_booking_repository.dart';

class BookingRepository implements IBookingRepository {
  final BookingRemoteDataSource _dataSource;
  BookingRepository({BookingRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? BookingRemoteDataSource();

  @override
  Future<BookingAvailabilityEntity> getAvailability(String courtId, DateTime date) async {
    final res = await _dataSource.getAvailability(courtId, date);
    if (res.isSuccess && res.result != null) {
      return _mapAvailabilityToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<BookingEntity> createBooking(BookingCreateRequest request) async {
    final res = await _dataSource.createBooking(request);
    if (res.isSuccess && res.result != null) {
      return _mapBookingToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  @override
  Future<List<BookingEntity>> getMyHistory({
    int page = 1,
    int pageSize = 10,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final res = await _dataSource.getMyHistory(
      page: page,
      pageSize: pageSize,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );
    if (res.isSuccess && res.result != null) {
      return res.result!.map(_mapBookingToEntity).toList();
    }
    throw Exception(res.message);
  }

  @override
  Future<BookingEntity> cancelBooking(String bookingId) async {
    final res = await _dataSource.cancelBooking(bookingId);
    if (res.isSuccess && res.result != null) {
      return _mapBookingToEntity(res.result!);
    }
    throw Exception(res.message);
  }

  BookingAvailabilityEntity _mapAvailabilityToEntity(BookingAvailabilityModel m) {
    return BookingAvailabilityEntity(
      courtId: m.courtId,
      date: m.date,
      openTime: m.openTime,
      closeTime: m.closeTime,
      slotMinutes: m.slotMinutes,
      slots: m.slots.map((s) => BookingSlotEntity(
        startTime: s.startTime,
        endTime: s.endTime,
        isAvailable: s.isAvailable,
      )).toList(),
    );
  }

  BookingEntity _mapBookingToEntity(BookingResponseModel m) {
    return BookingEntity(
      id: m.id,
      userId: m.userId,
      courtId: m.courtId,
      courtName: m.courtName,
      startTime: m.startTime,
      endTime: m.endTime,
      totalPrice: m.totalPrice,
      status: m.status,
      isPaid: m.isPaid,
      createdAt: m.createdAt,
      services: m.services.map((s) => BookingServiceItemEntity(
        serviceId: s.serviceId,
        serviceName: s.serviceName,
        quantity: s.quantity,
        priceAtBooking: s.priceAtBooking,
      )).toList(),
    );
  }
}
