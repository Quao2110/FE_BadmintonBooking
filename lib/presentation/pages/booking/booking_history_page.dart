import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../../shared/widgets/app_notification.dart';
import '../../bloc/booking/booking_bloc.dart';
import '../../bloc/booking/booking_event.dart';
import '../../bloc/booking/booking_state.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc.create()..add(const LoadMyHistoryEvent()),
      child: const _BookingHistoryView(),
    );
  }
}

class _BookingHistoryView extends StatelessWidget {
  const _BookingHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('Lịch sử đặt sân'),
        elevation: 0,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            AppNotification.showError(state.message);
          }
        },
        builder: (context, state) {
          if (state is BookingLoading ||
              (state is BookingHistoryLoaded && state.isLoading)) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is BookingError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<BookingBloc>().add(const LoadMyHistoryEvent()),
            );
          }

          if (state is BookingHistoryLoaded) {
            if (state.bookings.isEmpty) {
              return const _EmptyBookings();
            }
            return _BookingsList(bookings: state.bookings);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<BookingEntity> bookings;
  const _BookingsList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingBloc>().add(const LoadMyHistoryEvent());
      },
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _BookingCard(booking: bookings[index]);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sports_tennis,
                  size: 20,
                  color: _getStatusColor(booking.status),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.courtName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusBadge(status: booking.status, label: booking.statusLabel),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Ngày',
                  value: dateFormat.format(booking.startTime),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Giờ',
                  value: booking.timeLabel,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.payments,
                  label: 'Tổng tiền',
                  value: '${_formatCurrency(booking.totalPrice)}đ',
                  valueColor: AppColors.primary,
                ),
                if (booking.services.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _ServicesList(services: booking.services),
                ],
              ],
            ),
          ),

          // Actions
          if (booking.status.toLowerCase() == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCancelDialog(context, booking.id),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Hủy đặt'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showCancelDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy đặt sân này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BookingBloc>().add(CancelBookingEvent(bookingId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy đặt'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ServicesList extends StatelessWidget {
  final List<BookingServiceItemEntity> services;
  const _ServicesList({required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 4),
        const Text(
          'Dịch vụ đã đặt:',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        ...services.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 14, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${s.serviceName} x${s.quantity}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                '${_formatCurrency(s.lineTotal)}đ',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có lượt đặt sân nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy đặt sân ngay để trải nghiệm!',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCurrency(double value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && (idx - 1) % 3 == 0) buf.write('.');
  }
  return buf.toString();
}
