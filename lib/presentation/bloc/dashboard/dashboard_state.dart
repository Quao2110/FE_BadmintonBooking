import 'package:equatable/equatable.dart';
import '../../../domain/entities/dashboard_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final BookingRevenueEntity bookingRevenue;
  final OrderRevenueEntity orderRevenue;
  final String period; // 'day' | 'month' | 'year'

  const DashboardLoaded({
    required this.bookingRevenue,
    required this.orderRevenue,
    required this.period,
  });

  @override
  List<Object?> get props => [bookingRevenue, orderRevenue, period];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
