import '../../entities/dashboard_entity.dart';
import '../../repositories/i_dashboard_repository.dart';

class GetBookingRevenueUseCase {
  final IDashboardRepository repository;
  GetBookingRevenueUseCase(this.repository);

  /// [period]: 'day' | 'month' | 'year'
  Future<BookingRevenueEntity> call({String period = 'day'}) =>
      repository.getBookingRevenue(period: period);
}

class GetOrderRevenueUseCase {
  final IDashboardRepository repository;
  GetOrderRevenueUseCase(this.repository);

  Future<OrderRevenueEntity> call() => repository.getOrderRevenue();
}
