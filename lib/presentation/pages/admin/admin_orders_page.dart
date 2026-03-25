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
    setState(() { _isLoading = true; _error = null; });
    try {
      final orders = await _commerce.getOrders(
        orderStatus: _statusFilter, page: 1, pageSize: 10,
      );
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
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
        SnackBar(content: Text('Da cap nhat: $status'), backgroundColor: Colors.green),
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
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
        const SnackBar(content: Text('Da huy don hang'), backgroundColor: Colors.green),
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loi: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': case 'approved': return Colors.green;
      case 'shipping': return Colors.blue;
      case 'delivered': return Colors.teal;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _money(double value) {
    final fmt = NumberFormat('#,##0', 'vi_VN');
    return '${fmt.format(value.toInt())}d';
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      user: widget.user,
      currentRoute: AppRoutes.adminOrders,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + filters
            const Text(
              'Quan ly Don hang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _FilterChip(label: 'Tat ca', selected: _statusFilter == null, onTap: () { setState(() => _statusFilter = null); _loadOrders(); })),
                const SizedBox(width: 6),
                Expanded(child: _FilterChip(label: 'Pending', selected: _statusFilter == 'Pending', color: Colors.orange, onTap: () { setState(() => _statusFilter = 'Pending'); _loadOrders(); })),
                const SizedBox(width: 6),
                Expanded(child: _FilterChip(label: 'Confirmed', selected: _statusFilter == 'Confirmed', color: Colors.green, onTap: () { setState(() => _statusFilter = 'Confirmed'); _loadOrders(); })),
                const SizedBox(width: 6),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    padding: EdgeInsets.zero,
                    tooltip: 'Lam moi',
                    onPressed: _loadOrders,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadOrders, child: const Text('Thu lai')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(child: Text('Khong co don hang nao', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _OrderCard(
          order: order,
          statusColor: _statusColor(order.orderStatus),
          money: _money,
          isUpdating: _isUpdating,
          onConfirm: () => _updateStatus(order, 'Confirmed'),
          onShipping: () => _updateStatus(order, 'Shipping'),
          onCancel: () => _cancelOrder(order),
        );
      },
    );
  }
}

// ─── Order Card (vertical layout, no overflow) ────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final String Function(double) money;
  final bool isUpdating;
  final VoidCallback onConfirm;
  final VoidCallback onShipping;
  final VoidCallback onCancel;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.money,
    required this.isUpdating,
    required this.onConfirm,
    required this.onShipping,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.orderStatus.toLowerCase() == 'pending';
    final date = order.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(order.createdAt!)
        : '-';
    final productPreview = order.items.isNotEmpty
        ? order.items.first.productName
        : 'Khong co san pham';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: customer name + status
            Row(
              children: [
                Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customerName ?? order.customerEmail ?? 'Khach hang',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Product + date
            Text(
              productPreview,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              'Tong: ${money(order.totalAmount)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            // Actions for pending
            if (isPending) ...[
              const SizedBox(height: 8),
              if (_isUpdatingState(isUpdating))
                const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionBtn(icon: Icons.check_circle, color: Colors.green, label: 'Confirm', onTap: onConfirm),
                    const SizedBox(width: 8),
                    _ActionBtn(icon: Icons.flight_takeoff, color: Colors.blue, label: 'Ship', onTap: onShipping),
                    const SizedBox(width: 8),
                    _ActionBtn(icon: Icons.cancel, color: Colors.red, label: 'Huy', onTap: onCancel),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isUpdatingState(bool updating) => updating;
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final active = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? active.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? active : AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? active : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
