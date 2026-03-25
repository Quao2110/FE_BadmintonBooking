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

/// Admin Dashboard
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chao, ${widget.user.fullName?.split(' ').last ?? 'Admin'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quan ly he thong dat san cau long',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Error
              if (state is DashboardError)
                _ErrorBanner(
                  message: state.message,
                  onRetry: () {
                    context.read<DashboardBloc>().add(LoadDashboardEvent(period: _selectedPeriod));
                  },
                ),

              // Stats
              if (state is DashboardLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is DashboardLoaded) ...[
                _StatsGrid(state: state, user: widget.user),
                const SizedBox(height: 20),
                _BookingRevenueChart(
                  entity: state.bookingRevenue,
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (p) {
                    setState(() => _selectedPeriod = p);
                    context.read<DashboardBloc>().add(ChangeDashboardPeriodEvent(p));
                  },
                ),
                const SizedBox(height: 20),
                _TopProductsChart(orderRevenue: state.orderRevenue),
              ] else
                // Placeholder
                _PlaceholderStats(user: widget.user),
            ],
          ),
        );
      },
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardLoaded state;
  final User user;
  const _StatsGrid({required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'vi_VN');
    final br = state.bookingRevenue;
    final or = state.orderRevenue;

    final topProduct = or.topProducts.isNotEmpty ? or.topProducts.first.productName : '--';

    final items = <_StatData>[
      _StatData(Icons.attach_money_rounded, 'DT San', '${fmt.format(br.totalRevenue.toInt())}d', Colors.teal),
      _StatData(Icons.calendar_today_rounded, 'Dat san', '${br.totalBookings}', Colors.purple),
      _StatData(Icons.store_rounded, 'DT Hang', '${fmt.format(or.totalRevenue.toInt())}d', Colors.orange),
      _StatData(Icons.emoji_events_rounded, 'Top SP', topProduct, Colors.amber),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _StatCard(data: items[i]),
    );
  }
}

class _StatData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _StatData(this.icon, this.title, this.value, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data.title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder Stats ────────────────────────────────────────────────────────

class _PlaceholderStats extends StatelessWidget {
  final User user;
  const _PlaceholderStats({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <_StatData>[
      const _StatData(Icons.people_rounded, 'Users', '--', Colors.blue),
      const _StatData(Icons.sports_tennis_rounded, 'San', '--', Colors.green),
      const _StatData(Icons.shopping_bag_rounded, 'San pham', '--', Colors.orange),
      const _StatData(Icons.calendar_today_rounded, 'Bookings', '--', Colors.purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _StatCard(data: items[i]),
    );
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + period selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doanh thu Dat san',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'day', label: Text('Ngay', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: 'month', label: Text('Thang', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: 'year', label: Text('Nam', style: TextStyle(fontSize: 12))),
                  ],
                  selected: {selectedPeriod},
                  onSelectionChanged: (s) => onPeriodChanged(s.first),
                  style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (spots.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Khong co du lieu', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entity.revenuePoints.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              entity.revenuePoints[idx].label,
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          final fmt = NumberFormat.compact(locale: 'vi_VN');
                          return Text(fmt.format(value), style: const TextStyle(fontSize: 9, color: Colors.grey));
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
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.25),
                            AppColors.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 3,
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

// ─── Top Products Chart ───────────────────────────────────────────────────────

class _TopProductsChart extends StatelessWidget {
  final OrderRevenueEntity orderRevenue;
  const _TopProductsChart({required this.orderRevenue});

  @override
  Widget build(BuildContext context) {
    final top5 = orderRevenue.topProducts.take(5).toList();
    final maxSold = top5.isEmpty ? 1 : top5.map((p) => p.totalSold).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Top 5 San pham ban chay',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (top5.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Khong co du lieu', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...top5.asMap().entries.map((entry) {
              final i = entry.key;
              final product = entry.value;
              final ratio = maxSold > 0 ? product.totalSold / maxSold : 0.0;
              final colors = [Colors.amber, Colors.blue, Colors.green, Colors.orange, Colors.purple];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: i == 0 ? Colors.amber.shade700 : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 3,
                      child: Text(
                        product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade100,
                              color: colors[i % colors.length],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('${product.totalSold} sold', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
