import '../datasources/dashboard_api_service.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/i_dashboard_repository.dart';

class DashboardRepository implements IDashboardRepository {
  final DashboardRemoteDataSource _dataSource;
  DashboardRepository({DashboardRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? DashboardRemoteDataSource();

  @override
  Future<BookingRevenueEntity> getBookingRevenue({String period = 'day'}) async {
    final model = await _dataSource.getBookingRevenue(period: period);
    return model.toEntity();
  }

  @override
  Future<OrderRevenueEntity> getOrderRevenue() async {
    final model = await _dataSource.getOrderRevenue();
    return model.toEntity();
  }
}
