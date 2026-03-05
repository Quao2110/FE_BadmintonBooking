import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/booking/booking_create_request.dart';
import '../../../domain/entities/court_entity.dart';
import '../../../shared/widgets/app_notification.dart';
import '../../bloc/booking/booking_bloc.dart';
import '../../bloc/booking/booking_event.dart';
import '../../bloc/booking/booking_state.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingBloc.create()..add(const LoadCourtsEvent()),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatelessWidget {
  const _BookingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        title: const Text('Đặt sân cầu lông'),
        elevation: 0,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            AppNotification.showInfo('Đặt sân thành công!');
            Navigator.of(context).pop(state.booking);
          }
          if (state is BookingDataLoaded && state.error != null) {
            AppNotification.showError(state.error!);
          }
          if (state is BookingError) {
            AppNotification.showError(state.message);
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is BookingError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<BookingBloc>().add(const LoadCourtsEvent()),
            );
          }

          if (state is BookingDataLoaded) {
            return _BookingContent(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BookingContent extends StatelessWidget {
  final BookingDataLoaded state;
  const _BookingContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker Section
                _DatePickerSection(
                  selectedDate: state.selectedDate,
                  onDateChanged: (date) {
                    if (state.selectedCourt != null) {
                      context.read<BookingBloc>().add(LoadAvailabilityEvent(
                        courtId: state.selectedCourt!.id,
                        date: date,
                      ));
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Court Selection Section
                _CourtSelectionSection(
                  courts: state.courts,
                  selectedCourt: state.selectedCourt,
                  selectedDate: state.selectedDate,
                ),
                const SizedBox(height: 20),

                // Time Slots Section
                if (state.selectedCourt != null)
                  _TimeSlotsSection(
                    state: state,
                  ),

                // Services Section
                if (state.selectedSlotIndices.isNotEmpty && state.services.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _ServicesSection(state: state),
                ],

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),

        // Bottom Price & Book Button
        _BottomBookingBar(state: state),
      ],
    );
  }
}

class _DatePickerSection extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DatePickerSection({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.calendar_today, title: 'Chọn ngày'),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isSameDay(date, now);

              return _DateCard(
                date: date,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => onDateChanged(date),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DateCard({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = _getVietnameseDayName(date.weekday);
    final dayNum = date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.background : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.background : AppColors.textPrimary,
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.background : AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourtSelectionSection extends StatelessWidget {
  final List<CourtEntity> courts;
  final CourtEntity? selectedCourt;
  final DateTime selectedDate;

  const _CourtSelectionSection({
    required this.courts,
    required this.selectedCourt,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    if (courts.isEmpty) {
      return const _EmptyState(
        icon: Icons.sports_tennis,
        message: 'Không có sân nào khả dụng',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.sports_tennis, title: 'Chọn sân'),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: courts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final court = courts[index];
              final isSelected = selectedCourt?.id == court.id;

              return _CourtCard(
                court: court,
                isSelected: isSelected,
                onTap: () {
                  context.read<BookingBloc>().add(LoadAvailabilityEvent(
                    courtId: court.id,
                    date: selectedDate,
                  ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourtCard extends StatelessWidget {
  final CourtEntity court;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourtCard({
    required this.court,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = court.primaryImageUrl;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 80,
                width: double.infinity,
                color: AppColors.border,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        ApiConstants.getFullImageUrl(imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _courtPlaceholder(),
                      )
                    : _courtPlaceholder(),
              ),
            ),
            // Court Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.courtName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courtPlaceholder() {
    return Container(
      color: AppColors.border,
      child: const Center(
        child: Icon(
          Icons.sports_tennis,
          size: 32,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TimeSlotsSection extends StatelessWidget {
  final BookingDataLoaded state;

  const _TimeSlotsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionTitle(icon: Icons.schedule, title: 'Chọn giờ'),
            if (state.selectedSlotIndices.isNotEmpty)
              TextButton.icon(
                onPressed: () => context.read<BookingBloc>().add(const ClearSlotsEvent()),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Xóa chọn'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _SlotLegend(),
        const SizedBox(height: 12),
        if (state.isLoadingAvailability)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (state.availability != null)
          _SlotsGrid(
            slots: state.availability!.slots,
            selectedIndices: state.selectedSlotIndices,
            onSlotTap: (index) {
              context.read<BookingBloc>().add(SelectSlotEvent(index));
            },
          )
        else
          const _EmptyState(
            icon: Icons.schedule,
            message: 'Chọn sân để xem lịch trống',
          ),
      ],
    );
  }
}

class _SlotLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(color: AppColors.success.withOpacity(0.15), borderColor: AppColors.success, label: 'Còn trống'),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.grey.shade300, borderColor: Colors.grey, label: 'Đã đặt'),
        const SizedBox(width: 16),
        _LegendItem(color: AppColors.primary, borderColor: AppColors.primary, label: 'Đã chọn'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  final List slots;
  final Set<int> selectedIndices;
  final ValueChanged<int> onSlotTap;

  const _SlotsGrid({
    required this.slots,
    required this.selectedIndices,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedIndices.contains(index);
        final isAvailable = slot.isAvailable;

        return _SlotChip(
          timeLabel: slot.timeLabel,
          isSelected: isSelected,
          isAvailable: isAvailable,
          onTap: () => onSlotTap(index),
        );
      },
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String timeLabel;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  const _SlotChip({
    required this.timeLabel,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = AppColors.background;
    } else if (isAvailable) {
      bgColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
      textColor = AppColors.textPrimary;
    } else {
      bgColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey;
    }

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            timeLabel.split(' - ').first, // Show only start time for cleaner look
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final BookingDataLoaded state;

  const _ServicesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.add_shopping_cart, title: 'Dịch vụ thêm (tùy chọn)'),
        const SizedBox(height: 12),
        ...state.services.map((service) {
          final quantity = state.serviceQuantities[service.id] ?? 0;
          return _ServiceItem(
            name: service.serviceName,
            price: service.price,
            unit: service.unit,
            quantity: quantity,
            onQuantityChanged: (newQty) {
              context.read<BookingBloc>().add(UpdateServiceQuantityEvent(
                serviceId: service.id,
                quantity: newQty,
              ));
            },
          );
        }),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String name;
  final double price;
  final String unit;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _ServiceItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: quantity > 0 ? AppColors.primary : AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrice(price)}đ / $unit',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          _QuantitySelector(
            quantity: quantity,
            onChanged: onQuantityChanged,
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.remove,
          onTap: quantity > 0 ? () => onChanged(quantity - 1) : null,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _CircleButton(
          icon: Icons.add,
          onTap: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: isEnabled ? AppColors.background : Colors.grey),
      ),
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  final BookingDataLoaded state;

  const _BottomBookingBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng tiền',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatPrice(state.totalPrice)}đ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (state.selectedSlotIndices.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${state.selectedSlotIndices.length} slot(s) đã chọn',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: state.canBook ? () => _onBookPressed(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  elevation: state.canBook ? 4 : 0,
                ),
                child: state.isCreating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Đặt sân',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBookPressed(BuildContext context) {
    final selectedCourt = state.selectedCourt;
    final startTime = state.selectedStartTime;
    final endTime = state.selectedEndTime;

    print('[BOOKING] onBookPressed called');
    print('[BOOKING] selectedCourt: ${selectedCourt?.id}');
    print('[BOOKING] startTime: $startTime');
    print('[BOOKING] endTime: $endTime');
    print('[BOOKING] availability: ${state.availability}');
    print('[BOOKING] selectedSlotIndices: ${state.selectedSlotIndices}');

    if (selectedCourt == null || startTime == null || endTime == null) {
      print('[BOOKING] Early return - something is null!');
      return;
    }

    // Build service items
    final serviceItems = <BookingServiceItemRequest>[];
    for (final entry in state.serviceQuantities.entries) {
      if (entry.value > 0) {
        serviceItems.add(BookingServiceItemRequest(
          serviceId: entry.key,
          quantity: entry.value,
        ));
      }
    }

    final request = BookingCreateRequest(
      courtId: selectedCourt.id,
      startTime: startTime,
      endTime: endTime,
      serviceItems: serviceItems.isNotEmpty ? serviceItems : null,
    );

    context.read<BookingBloc>().add(CreateBookingEvent(request));
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
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

/// Lấy tên thứ bằng tiếng Việt
String _getVietnameseDayName(int weekday) {
  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  return days[weekday - 1];
}

String _formatPrice(double value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && (idx - 1) % 3 == 0) buf.write('.');
  }
  return buf.toString();
}
