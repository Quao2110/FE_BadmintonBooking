import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../data/datasources/booking_api_service.dart';
import '../../../presentation/bloc/booking/booking_bloc.dart';
import '../../../presentation/bloc/booking/booking_event.dart';
import '../../../presentation/bloc/booking/booking_state.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';
import 'package:intl/intl.dart';

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

  Future<void> _updateStatus(BuildContext context, BookingEntity booking, String status) async {
    setState(() => _isUpdating = true);
    try {
      final svc = BookingRemoteDataSource();
      await svc.updateBookingStatus(booking.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Da cap nhat: $status'), backgroundColor: Colors.green),
        );
        context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _cancelBooking(BuildContext context, BookingEntity booking) async {
    setState(() => _isUpdating = true);
    try {
      final svc = BookingRemoteDataSource();
      await svc.cancelBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da huy booking'), backgroundColor: Colors.green),
        );
        context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Quan ly Dat san',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          // Filters
          Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: 'Tat ca',
                  selected: _statusFilter == null,
                  onTap: () {
                    setState(() => _statusFilter = null);
                    context.read<BookingBloc>().add(const LoadMyHistoryEvent());
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _FilterChip(
                  label: 'Pending',
                  selected: _statusFilter == 'Pending',
                  color: Colors.orange,
                  onTap: () {
                    setState(() => _statusFilter = 'Pending');
                    context.read<BookingBloc>().add(const LoadMyHistoryEvent(status: 'Pending'));
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _FilterChip(
                  label: 'Confirmed',
                  selected: _statusFilter == 'Confirmed',
                  color: Colors.green,
                  onTap: () {
                    setState(() => _statusFilter = 'Confirmed');
                    context.read<BookingBloc>().add(const LoadMyHistoryEvent(status: 'Confirmed'));
                  },
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  padding: EdgeInsets.zero,
                  tooltip: 'Lam moi',
                  onPressed: () => context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                        const Icon(Icons.error_outline, size: 40, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.read<BookingBloc>().add(LoadMyHistoryEvent(status: _statusFilter)),
                          child: const Text('Thu lai'),
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
                          Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Khong co dat san nao', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = state.bookings[index];
                      return _BookingCard(
                        booking: booking,
                        isUpdating: _isUpdating,
                        onApprove: () => _updateStatus(context, booking, 'Confirmed'),
                        onCancel: () => _cancelBooking(context, booking),
                      );
                    },
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

// ─── Booking Card (vertical, mobile-friendly) ────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final bool isUpdating;
  final VoidCallback onApprove;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.isUpdating,
    required this.onApprove,
    required this.onCancel,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': case 'approved': return Colors.green;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy', 'vi_VN');
    final timeFmt = DateFormat('HH:mm');
    final moneyFmt = NumberFormat('#,##0', 'vi_VN');
    final isPending = booking.status.toLowerCase() == 'pending';
    final statusColor = _statusColor(booking.status);

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
            // Court name + status
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.courtName,
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
                    booking.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date/time
            Text(
              '${fmt.format(booking.startTime)} ${timeFmt.format(booking.startTime)} - ${timeFmt.format(booking.endTime)}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            // Price
            Text(
              'Tong tien: ${moneyFmt.format(booking.totalPrice.toInt())}d',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            // Services
            if (booking.services.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Dich vu: ${booking.services.map((s) => s.serviceName).join(', ')}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Actions
            if (isPending) ...[
              const SizedBox(height: 8),
              if (isUpdating)
                const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionBtn(icon: Icons.check_circle, color: Colors.green, label: 'Approve', onTap: onApprove),
                    const SizedBox(width: 8),
                    _ActionBtn(icon: Icons.cancel, color: Colors.red, label: 'Cancel', onTap: onCancel),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

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
