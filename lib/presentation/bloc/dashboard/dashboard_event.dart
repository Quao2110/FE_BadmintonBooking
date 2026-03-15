import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

/// Load toàn bộ dữ liệu dashboard
class LoadDashboardEvent extends DashboardEvent {
  final String period; // 'day' | 'month' | 'year'
  const LoadDashboardEvent({this.period = 'day'});
  @override
  List<Object?> get props => [period];
}

/// Thay đổi kỳ thống kê (ngày/tháng/năm)
class ChangeDashboardPeriodEvent extends DashboardEvent {
  final String period;
  const ChangeDashboardPeriodEvent(this.period);
  @override
  List<Object?> get props => [period];
}
