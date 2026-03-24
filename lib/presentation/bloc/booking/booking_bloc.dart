import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../data/repositories/court_repository_impl.dart';
import '../../../data/repositories/service_repository_impl.dart';
import '../../../domain/repositories/i_booking_repository.dart';
import '../../../domain/repositories/i_court_repository.dart';
import '../../../domain/repositories/i_service_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final ICourtRepository courtRepository;
  final IBookingRepository bookingRepository;
  final IServiceRepository serviceRepository;

  BookingBloc({
    required this.courtRepository,
    required this.bookingRepository,
    required this.serviceRepository,
  }) : super(const BookingInitial()) {
    on<LoadCourtsEvent>(_onLoadCourts);
    on<ChangeDateEvent>(_onChangeDate);
    on<LoadAvailabilityEvent>(_onLoadAvailability);
    on<SelectSlotEvent>(_onSelectSlot);
    on<ClearSlotsEvent>(_onClearSlots);
    on<LoadServicesEvent>(_onLoadServices);
    on<UpdateServiceQuantityEvent>(_onUpdateServiceQuantity);
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadMyHistoryEvent>(_onLoadMyHistory);
    on<CancelBookingEvent>(_onCancelBooking);
  }

  factory BookingBloc.create() {
    return BookingBloc(
      courtRepository: CourtRepository(),
      bookingRepository: BookingRepository(),
      serviceRepository: ServiceRepository(),
    );
  }

  Future<void> _onLoadCourts(LoadCourtsEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    try {
      final courts = await courtRepository.getAll();
      // Lọc chỉ lấy sân active
      final activeCourts = courts.where((c) => c.status.toLowerCase() == 'active').toList();
      final services = await serviceRepository.getAll();
      final now = DateTime.now();

      emit(BookingDataLoaded(
        courts: activeCourts,
        selectedDate: DateTime(now.year, now.month, now.day),
        services: services.where((s) => s.isActive).toList(),
      ));
    } catch (e) {
      emit(BookingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onChangeDate(ChangeDateEvent event, Emitter<BookingState> emit) async {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);

    emit(currentState.copyWith(
      selectedDate: normalizedDate,
      selectedSlotIndices: {},
      clearAvailability: true,
      clearError: true,
    ));

    final selectedCourt = currentState.selectedCourt;
    if (selectedCourt != null) {
      add(LoadAvailabilityEvent(
        courtId: selectedCourt.id,
        date: normalizedDate,
      ));
    }
  }

  Future<void> _onLoadAvailability(LoadAvailabilityEvent event, Emitter<BookingState> emit) async {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    final selectedCourt = currentState.courts.firstWhere((c) => c.id == event.courtId);

    emit(currentState.copyWith(
      selectedCourt: selectedCourt,
      selectedDate: event.date,
      isLoadingAvailability: true,
      selectedSlotIndices: {},
      clearError: true,
    ));

    try {
      final availability = await bookingRepository.getAvailability(event.courtId, event.date);

      // Re-check state after async operation
      final newState = state;
      if (newState is BookingDataLoaded) {
        emit(newState.copyWith(
          availability: availability,
          isLoadingAvailability: false,
        ));
      }
    } catch (e) {
      final newState = state;
      if (newState is BookingDataLoaded) {
        emit(newState.copyWith(
          isLoadingAvailability: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ));
      }
    }
  }

  void _onSelectSlot(SelectSlotEvent event, Emitter<BookingState> emit) {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;
    if (currentState.availability == null) return;

    final slot = currentState.availability!.slots[event.slotIndex];
    if (!slot.isAvailable) return;
    if (!slot.startTime.isAfter(DateTime.now())) return;

    final newSelection = Set<int>.from(currentState.selectedSlotIndices);
    if (newSelection.contains(event.slotIndex)) {
      newSelection.remove(event.slotIndex);
    } else {
      newSelection.add(event.slotIndex);
    }

    emit(currentState.copyWith(selectedSlotIndices: newSelection));
  }

  void _onClearSlots(ClearSlotsEvent event, Emitter<BookingState> emit) {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;
    emit(currentState.copyWith(selectedSlotIndices: {}));
  }

  Future<void> _onLoadServices(LoadServicesEvent event, Emitter<BookingState> emit) async {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    try {
      final services = await serviceRepository.getAll();
      emit(currentState.copyWith(
        services: services.where((s) => s.isActive).toList(),
      ));
    } catch (e) {
      // Ignore service loading errors
    }
  }

  void _onUpdateServiceQuantity(UpdateServiceQuantityEvent event, Emitter<BookingState> emit) {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    final newQuantities = Map<String, int>.from(currentState.serviceQuantities);
    if (event.quantity <= 0) {
      newQuantities.remove(event.serviceId);
    } else {
      newQuantities[event.serviceId] = event.quantity;
    }

    emit(currentState.copyWith(serviceQuantities: newQuantities));
  }

  Future<void> _onCreateBooking(CreateBookingEvent event, Emitter<BookingState> emit) async {
    print('[BLOC] _onCreateBooking called');
    print('[BLOC] Request: ${event.request.toJson()}');

    final currentState = state;
    if (currentState is! BookingDataLoaded) {
      print('[BLOC] Early return - not BookingDataLoaded');
      return;
    }

    emit(currentState.copyWith(isCreating: true, clearError: true));
    print('[BLOC] Calling API...');

    try {
      final booking = await bookingRepository.createBooking(event.request);
      print('[BLOC] API Success! Booking: ${booking.id}');
      emit(BookingCreated(booking));
    } catch (e) {
      print('[BLOC] API Error: $e');
      emit(currentState.copyWith(
        isCreating: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMyHistory(LoadMyHistoryEvent event, Emitter<BookingState> emit) async {
    emit(const BookingHistoryLoaded(bookings: [], isLoading: true));

    try {
      final bookings = await bookingRepository.getMyHistory(
        page: event.page,
        pageSize: event.pageSize,
        status: event.status,
      );
      emit(BookingHistoryLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCancelBooking(CancelBookingEvent event, Emitter<BookingState> emit) async {
    final currentState = state;
    if (currentState is! BookingHistoryLoaded) return;

    emit(BookingHistoryLoaded(bookings: currentState.bookings, isLoading: true));

    try {
      await bookingRepository.cancelBooking(event.bookingId);
      // Reload history
      final bookings = await bookingRepository.getMyHistory();
      emit(BookingHistoryLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
