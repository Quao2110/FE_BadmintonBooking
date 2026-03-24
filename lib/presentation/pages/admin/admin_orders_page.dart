import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user.dart';
import '../../../core/theme/colors.dart';
import '../../../data/datasources/commerce_api_service.dart';
import '../../../data/models/commerce/order_model.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';

class AdminOrdersPage extends StatefulWidget {
  final User user;

  const AdminOrdersPage({super.key, required this.user});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final CommerceApiService _commerce = CommerceApiService();

  List<OrderModel> _orders = const [];
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;
  String? _statusFilter;

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
      final orders = await _commerce.getOrders(
        orderStatus: _statusFilter,
        page: 1,
        pageSize: 10,
      );
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(OrderModel order, String status) async {
    setState(() => _isUpdating = true);
    try {
      await _commerce.updateOrderStatus(orderId: order.id, status: status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật trạng thái đơn: $status'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _cancelOrder(OrderModel order) async {
    setState(() => _isUpdating = true);
    try {
      await _commerce.cancelOrder(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn hàng thành công'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'approved':
        return Colors.green;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _money(double value) {
    final fmt = NumberFormat('#,##0', 'vi_VN');
    return '${fmt.format(value.toInt())}₫';
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      user: widget.user,
      currentRoute: AppRoutes.adminOrders,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              runSpacing: 10,
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Quản lý Đơn hàng',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                _StatusChip(
                  label: 'Tất cả',
                  selected: _statusFilter == null,
                  onTap: () {
                    setState(() => _statusFilter = null);
                    _loadOrders();
                  },
                ),
                _StatusChip(
                  label: 'Pending',
                  selected: _statusFilter == 'Pending',
                  color: Colors.orange,
                  onTap: () {
                    setState(() => _statusFilter = 'Pending');
                    _loadOrders();
                  },
                ),
                _StatusChip(
                  label: 'Confirmed',
                  selected: _statusFilter == 'Confirmed',
                  color: Colors.green,
                  onTap: () {
                    setState(() => _statusFilter = 'Confirmed');
                    _loadOrders();
                  },
                ),
                ElevatedButton.icon(
                  onPressed: _loadOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadOrders,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có đơn hàng nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final isPending =
                            order.orderStatus.toLowerCase() == 'pending';
                        final statusColor = _statusColor(order.orderStatus);
                        final date = order.createdAt != null
                            ? DateFormat(
                                'dd/MM/yyyy HH:mm',
                                'vi_VN',
                              ).format(order.createdAt!)
                            : '-';
                        final productPreview = order.items.isNotEmpty
                            ? order.items.first.productName
                            : 'Không có sản phẩm';

                        return ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.local_shipping,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            '#${order.id} - ${order.customerName ?? order.customerEmail ?? 'Khách hàng'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '$productPreview | $date',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tổng tiền: ${_money(order.totalAmount)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.orderStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (isPending && !_isUpdating) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  tooltip: 'Confirm',
                                  onPressed: () =>
                                      _updateStatus(order, 'Confirmed'),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.flight_takeoff,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Shipping',
                                  onPressed: () =>
                                      _updateStatus(order, 'Shipping'),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Hủy đơn',
                                  onPressed: () => _cancelOrder(order),
                                ),
                              ],
                              if (_isUpdating && isPending)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final active = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? active.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? active : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? active : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
