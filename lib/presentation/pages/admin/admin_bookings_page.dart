import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../data/datasources/booking_api_service.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../presentation/bloc/booking/booking_bloc.dart';
import '../../../presentation/bloc/booking/booking_event.dart';
import '../../../presentation/bloc/booking/booking_state.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';
import 'package:intl/intl.dart';

/// Admin quản lý tất cả bookings – Approve / Reject
class AdminBookingsPage extends StatelessWidget {
  final User user;
  const AdminBookingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc.create()..add(const LoadMyHistoryEvent()),
      child: AdminLayout(
        user: user,
        currentRoute: AppRoutes.adminBookings,
        child: _AdminBookingsBody(adminUser: user),
      ),
    );
  }
}

class _AdminBookingsBody extends StatefulWidget {
  final User adminUser;
  const _AdminBookingsBody({required this.adminUser});

  @override
  State<_AdminBookingsBody> createState() => _AdminBookingsBodyState();
}

class _AdminBookingsBodyState extends State<_AdminBookingsBody> {
  String? _statusFilter;
  bool _isUpdating = false;

  Future<void> _updateStatus(
      BuildContext context, BookingEntity booking, String status) async {
    setState(() => _isUpdating = true);
    try {
      final svc = BookingRemoteDataSource();
      await svc.updateBookingStatus(booking.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái: $status'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload list
        context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quản lý Đặt sân',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Filter chips
              _FilterChip(
                label: 'Tất cả',
                selected: _statusFilter == null,
                onTap: () {
                  setState(() => _statusFilter = null);
                  context.read<BookingBloc>().add(const LoadMyHistoryEvent());
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending',
                selected: _statusFilter == 'Pending',
                color: Colors.orange,
                onTap: () {
                  setState(() => _statusFilter = 'Pending');
                  context.read<BookingBloc>().add(const LoadMyHistoryEvent(status: 'Pending'));
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Approved',
                selected: _statusFilter == 'Approved',
                color: Colors.green,
                onTap: () {
                  setState(() => _statusFilter = 'Approved');
                  context.read<BookingBloc>().add(const LoadMyHistoryEvent(status: 'Approved'));
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Làm mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingHistoryLoaded && state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BookingError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(state.message, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter)),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is BookingHistoryLoaded) {
                  if (state.bookings.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Không có đặt sân nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
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
                      itemCount: state.bookings.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final booking = state.bookings[index];
                        return _BookingTile(
                          booking: booking,
                          isUpdating: _isUpdating,
                          onApprove: () => _updateStatus(context, booking, 'Approved'),
                          onReject: () => _updateStatus(context, booking, 'Rejected'),
                        );
                      },
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final BookingEntity booking;
  final bool isUpdating;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingTile({
    required this.booking,
    required this.isUpdating,
    required this.onApprove,
    required this.onReject,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
    final moneyFmt = NumberFormat('#,##0', 'vi_VN');
    final isPending = booking.status.toLowerCase() == 'pending';
    final statusColor = _statusColor(booking.status);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
      ),
      title: Text(
        booking.courtName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('${fmt.format(booking.startTime)} → ${DateFormat('HH:mm').format(booking.endTime)}'),
          const SizedBox(height: 2),
          Text(
            'Tổng tiền: ${moneyFmt.format(booking.totalPrice.toInt())}₫',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
          if (booking.services.isNotEmpty)
            Text('Dịch vụ: ${booking.services.map((s) => s.serviceName).join(', ')}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          if (isPending && !isUpdating) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              tooltip: 'Approve',
              onPressed: onApprove,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.red, size: 28),
              tooltip: 'Reject',
              onPressed: onReject,
            ),
          ] else if (isUpdating && isPending) ...[
            const SizedBox(width: 12),
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ],
      ),
    );
  }
}
