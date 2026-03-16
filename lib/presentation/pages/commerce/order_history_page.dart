import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../data/datasources/commerce_api_service.dart';
import '../../../data/models/commerce/order_model.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../shared/widgets/empty_widget.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('My History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Orders'),
            Tab(icon: Icon(Icons.sports_tennis), text: 'Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OrderTab(), _BookingTab()],
      ),
    );
  }
}

class _OrderTab extends StatefulWidget {
  const _OrderTab();

  @override
  State<_OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<_OrderTab> {
  final CommerceApiService _commerce = CommerceApiService();

  bool _isLoading = true;
  String? _error;
  List<OrderModel> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _commerce.getMyOrders();
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const EmptyWidget(
        icon: Icons.receipt_long_outlined,
        message: 'No orders yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _OrderCard(order: _orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!)
        : '-';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _Tag(label: order.status, color: _statusColor(order.status)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Created at: $date',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Tag(label: order.paymentMethod, color: AppColors.primary),
              const SizedBox(width: 8),
              _Tag(
                label: order.paymentStatus,
                color: order.isPaid ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Total: VND ${_formatMoney(order.totalAmount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...order.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('x${item.quantity}'),
                      ],
                    ),
                  ),
                ),
            if (order.items.length > 2)
              Text(
                '+${order.items.length - 2} more items',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
          ],
        ],
      ),
    );
  }
}

class _BookingTab extends StatefulWidget {
  const _BookingTab();

  @override
  State<_BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<_BookingTab> {
  final BookingRepository _bookingRepository = BookingRepository();

  bool _isLoading = true;
  String? _error;
  List<BookingEntity> _bookings = const [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _bookingRepository.getMyHistory(
        page: 1,
        pageSize: 20,
      );
      if (!mounted) return;
      setState(() => _bookings = bookings);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const EmptyWidget(
        icon: Icons.event_busy_outlined,
        message: 'No bookings yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.sports_tennis, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(booking.startTime),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _Tag(
                  label: booking.statusLabel,
                  color: _statusColor(booking.status),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'paid':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'cancelled':
    case 'failed':
      return Colors.red;
    default:
      return AppColors.primary;
  }
}

String _formatMoney(double value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) {
      buf.write('.');
    }
  }
  return buf.toString();
}
