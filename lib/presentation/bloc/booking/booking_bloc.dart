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
      final activeCourts = courts.where((c) => c.status.toLowerCase() == 'active' || c.status.toLowerCase() == 'available').toList();
      final services = await serviceRepository.getAll();
      
      final now = DateTime.now();
      emit(BookingDataLoaded(
        courts: activeCourts,
        selectedDate: now,
        services: services.where((s) => s.isActive).toList(),
      ));

      // Auto-select court if initialCourtId provided
      if (event.initialCourtId != null) {
        if (activeCourts.any((c) => c.id == event.initialCourtId)) {
          add(LoadAvailabilityEvent(
            courtId: event.initialCourtId!,
            date: now,
          ));
        }
      }
    } catch (e) {
      emit(BookingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Thay đổi ngày - nếu đã chọn sân thì load lại availability
  void _onChangeDate(ChangeDateEvent event, Emitter<BookingState> emit) {
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    // Chỉ update ngày, clear slot đã chọn
    emit(currentState.copyWith(
      selectedDate: event.date,
      selectedSlotIndices: {},
      clearAvailability: true,
      clearError: true,
    ));

    // Nếu đã chọn sân, tự động load availability cho ngày mới
    if (currentState.selectedCourt != null) {
      add(LoadAvailabilityEvent(
        courtId: currentState.selectedCourt!.id,
        date: event.date,
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
    final currentState = state;
    if (currentState is! BookingDataLoaded) return;

    emit(currentState.copyWith(isCreating: true, clearError: true));

    try {
      final booking = await bookingRepository.createBooking(event.request);
      emit(BookingCreated(booking));
    } catch (e) {
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
