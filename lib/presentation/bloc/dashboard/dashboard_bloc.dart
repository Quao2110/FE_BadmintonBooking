import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/dashboard/dashboard_usecases.dart';
import '../../../data/repositories/dashboard_repository_impl.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetBookingRevenueUseCase _getBookingRevenue;
  final GetOrderRevenueUseCase _getOrderRevenue;

  DashboardBloc({
    GetBookingRevenueUseCase? getBookingRevenue,
    GetOrderRevenueUseCase? getOrderRevenue,
  })  : _getBookingRevenue =
            getBookingRevenue ?? GetBookingRevenueUseCase(DashboardRepository()),
        _getOrderRevenue =
            getOrderRevenue ?? GetOrderRevenueUseCase(DashboardRepository()),
        super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
    on<ChangeDashboardPeriodEvent>(_onChangePeriod);
  }

  Future<void> _onLoad(
      LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final bookingRevenue = await _getBookingRevenue(period: event.period);
      final orderRevenue = await _getOrderRevenue();
      emit(DashboardLoaded(
        bookingRevenue: bookingRevenue,
        orderRevenue: orderRevenue,
        period: event.period,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onChangePeriod(
      ChangeDashboardPeriodEvent event, Emitter<DashboardState> emit) async {
    // Lấy state hiện tại để giữ orderRevenue, chỉ reload bookingRevenue
    final previousState = state;
    emit(DashboardLoading());
    try {
      final bookingRevenue =
          await _getBookingRevenue(period: event.period);
      emit(DashboardLoaded(
        bookingRevenue: bookingRevenue,
        orderRevenue: previousState is DashboardLoaded
            ? previousState.orderRevenue
            : await _getOrderRevenue(),
        period: event.period,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
