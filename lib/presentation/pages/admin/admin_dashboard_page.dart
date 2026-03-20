import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/dashboard_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../presentation/bloc/dashboard/dashboard_event.dart';
import '../../../presentation/bloc/dashboard/dashboard_state.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';

/// Admin Dashboard - Trang tổng quan với biểu đồ thống kê thật
class AdminDashboardPage extends StatelessWidget {
  final User user;

  const AdminDashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(const LoadDashboardEvent(period: 'day')),
      child: AdminLayout(
        user: user,
        currentRoute: AppRoutes.adminDashboard,
        child: _DashboardBody(user: user),
      ),
    );
  }
}

class _DashboardBody extends StatefulWidget {
  final User user;
  const _DashboardBody({required this.user});

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  String _selectedPeriod = 'day';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào mừng trở lại, ${widget.user.fullName?.split(' ').last ?? 'Admin'}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quản lý hệ thống đặt sân cầu lông',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Error state
              if (state is DashboardError)
                _ErrorBanner(message: state.message, onRetry: () {
                  context.read<DashboardBloc>().add(LoadDashboardEvent(period: _selectedPeriod));
                }),

              // Stats Cards
              const Text(
                'Tổng quan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (state is DashboardLoading)
                const Center(child: CircularProgressIndicator())
              else if (state is DashboardLoaded) ...[
                _StatsCards(state: state, user: widget.user),
                const SizedBox(height: 24),
                _BookingRevenueChart(
                  entity: state.bookingRevenue,
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (p) {
                    setState(() => _selectedPeriod = p);
                    context.read<DashboardBloc>().add(ChangeDashboardPeriodEvent(p));
                  },
                ),
                const SizedBox(height: 24),
                _TopProductsChart(orderRevenue: state.orderRevenue),
              ] else ...[
                // Fallback stat cards (placeholder khi chưa load)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return GridView.count(
                      crossAxisCount: isMobile ? 2 : 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isMobile ? 1.4 : 1.5,
                      children: [
                        _StatCard(icon: Icons.people_rounded, title: 'Users', value: '--', color: Colors.blue, onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.admin, arguments: widget.user)),
                        _StatCard(icon: Icons.sports_tennis_rounded, title: 'Sân', value: '--', color: Colors.green, onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminCourts, arguments: widget.user)),
                        _StatCard(icon: Icons.shopping_bag_rounded, title: 'Sản phẩm', value: '--', color: Colors.orange, onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.adminProducts, arguments: widget.user)),
                        _StatCard(icon: Icons.calendar_today_rounded, title: 'Bookings', value: '--', color: Colors.purple, onTap: () {}),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Stats Cards (khi đã load) ────────────────────────────────────────────────

class _StatsCards extends StatelessWidget {
  final DashboardLoaded state;
  final User user;
  const _StatsCards({required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'vi_VN');
    final bookingRevenue = state.bookingRevenue;
    final orderRevenue = state.orderRevenue;

    // Top sản phẩm bán chạy nhất
    final topProduct = orderRevenue.topProducts.isNotEmpty
        ? orderRevenue.topProducts.first.productName
        : '--';

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return GridView.count(
        crossAxisCount: isMobile ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isMobile ? 1.2 : 1.4,
        children: [
          _StatCard(
            icon: Icons.attach_money_rounded,
            title: 'Doanh thu Sân',
            value: '${fmt.format(bookingRevenue.totalRevenue.toInt())}₫',
            color: Colors.teal,
            onTap: () {},
          ),
          _StatCard(
            icon: Icons.calendar_today_rounded,
            title: 'Lượt đặt sân',
            value: '${bookingRevenue.totalBookings}',
            color: Colors.purple,
            onTap: () => Navigator.pushReplacementNamed(
                context, AppRoutes.adminBookings,
                arguments: user),
          ),
          _StatCard(
            icon: Icons.store_rounded,
            title: 'Doanh thu Hàng',
            value: '${fmt.format(orderRevenue.totalRevenue.toInt())}₫',
            color: Colors.orange,
            onTap: () {},
          ),
          _StatCard(
            icon: Icons.emoji_events_rounded,
            title: 'Top Sản phẩm',
            value: topProduct,
            color: Colors.amber,
            onTap: () {},
            smallText: true,
          ),
        ],
      );
    });
  }
}

// ─── Booking Revenue Chart ────────────────────────────────────────────────────

class _BookingRevenueChart extends StatelessWidget {
  final BookingRevenueEntity entity;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const _BookingRevenueChart({
    required this.entity,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spots = entity.revenuePoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Doanh thu Đặt sân',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Period selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Ngày')),
                  ButtonSegment(value: 'month', label: Text('Tháng')),
                  ButtonSegment(value: 'year', label: Text('Năm')),
                ],
                selected: {selectedPeriod},
                onSelectionChanged: (s) => onPeriodChanged(s.first),
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (spots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: null,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entity.revenuePoints.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              entity.revenuePoints[idx].label,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        getTitlesWidget: (value, meta) {
                          final fmt = NumberFormat.compact(locale: 'vi_VN');
                          return Text(
                            fmt.format(value),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Top Products Bar Chart ───────────────────────────────────────────────────

class _TopProductsChart extends StatelessWidget {
  final OrderRevenueEntity orderRevenue;
  const _TopProductsChart({required this.orderRevenue});

  @override
  Widget build(BuildContext context) {
    final top5 = orderRevenue.topProducts.take(5).toList();
    final maxSold = top5.isEmpty ? 1 : top5.map((p) => p.totalSold).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Top 5 Sản phẩm bán chạy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          if (top5.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey))))
          else
            ...top5.asMap().entries.map((entry) {
              final i = entry.key;
              final product = entry.value;
              final ratio = maxSold > 0 ? product.totalSold / maxSold : 0.0;
              final colors = [Colors.amber, Colors.blue, Colors.green, Colors.orange, Colors.purple];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: i == 0 ? Colors.amber.shade700 : Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade100,
                              color: colors[i % colors.length],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('${product.totalSold} sold',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

/// Stat Card Widget
 class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final bool smallText;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: smallText ? 13 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                ],
              ),
            // ),
          ],
        ),
      ),
    );
  }
}
