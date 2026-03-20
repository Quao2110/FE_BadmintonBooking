import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../../core/theme/colors.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';

class AdminOrdersPage extends StatefulWidget {
  final User user;

  const AdminOrdersPage({super.key, required this.user});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  // Mock data for UI
  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'OD-5001',
      'user': 'Nguyen Van A',
      'product': 'Vợt Cầu Lông Yonex',
      'date': '2023-11-01',
      'status': 'Pending',
      'total': '1,500,000 VND'
    },
    {
      'id': 'OD-5002',
      'user': 'Tran Thi B',
      'product': 'Giày Cầu Lông Lining',
      'date': '2023-11-02',
      'status': 'Approved', // Or Shipping
      'total': '1,200,000 VND'
    },
  ];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quản lý Đơn hàng',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.border),
                ),
                child: ListView.separated(
                  itemCount: _mockOrders.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final order = _mockOrders[index];
                    final isPending = order['status'] == 'Pending';
                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.local_shipping, color: AppColors.primary),
                      ),
                      title: Text(
                        '${order['id']} - ${order['user']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${order['product']} | ${order['date']}'),
                          const SizedBox(height: 4),
                          Text(
                            'Tổng tiền: ${order['total']}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isPending ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['status'],
                              style: TextStyle(
                                color: isPending ? Colors.orange : Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (isPending) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              tooltip: 'Approve',
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.flight_takeoff, color: Colors.blue),
                              tooltip: 'Shipping',
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: 'Reject',
                              onPressed: () {},
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
