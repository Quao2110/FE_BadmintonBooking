import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../bloc/service/service_bloc.dart';
import '../../bloc/service/service_event.dart';
import '../../bloc/service/service_state.dart';

class ServiceDetailPage extends StatefulWidget {
  final String serviceId;
  const ServiceDetailPage({super.key, required this.serviceId});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late final ServiceBloc _serviceBloc;
  int _qty = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serviceBloc = ServiceBloc.create()..add(GetServiceByIdEvent(widget.serviceId));
  }

  @override
  void dispose() {
    _serviceBloc.close();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceBloc>.value(
      value: _serviceBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          title: const Text('Chi tiết dịch vụ'),
        ),
        body: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            if (state is ServiceLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ServiceLoaded) {
              final service = state.service;
              final isAvailable = service.isActive && service.stockQuantity > 0;
              return SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _IconCard(),
                            const SizedBox(height: 12),
                            Text(
                              service.serviceName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đơn vị: ${service.unit}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            _SectionCard(
                              child: Column(
                                children: [
                                  _InfoRow(
                                    label: 'Giá',
                                    value: '₫${_formatCurrency(service.price)}',
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    label: 'Tồn kho',
                                    value: '${service.stockQuantity}',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _SectionCard(
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text('Số lượng', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  _QtySelector(
                                    value: _qty,
                                    max: service.stockQuantity,
                                    onChanged: (v) => setState(() => _qty = v),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ngày sử dụng', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  _PickerRow(
                                    text: _selectedDate == null
                                        ? 'Chọn ngày'
                                        : _formatDate(_selectedDate!),
                                    icon: Icons.calendar_today,
                                    onTap: _pickDate,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Giờ bắt đầu', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  _PickerRow(
                                    text: _selectedTime == null
                                        ? 'Chọn giờ'
                                        : _selectedTime!.format(context),
                                    icon: Icons.access_time,
                                    onTap: _pickTime,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _noteController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Ví dụ: cần huấn luyện viên kèm...',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        child: Column(
                          children: [
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: isAvailable
                                    ? () {
                                        if (_selectedDate == null || _selectedTime == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Vui lòng chọn ngày và giờ sử dụng.'),
                                              behavior: SnackBarBehavior.floating,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Đã đặt dịch vụ!'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text(isAvailable ? 'Đặt dịch vụ' : 'Hết dịch vụ'),
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
            if (state is ServiceError) {
              return _InlineError(
                message: state.message,
                onRetry: () => _serviceBloc.add(GetServiceByIdEvent(widget.serviceId)),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerRow({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Icon(Icons.build, size: 80, color: AppColors.accent),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  const _QtySelector({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canInc = max <= 0 ? false : value < max;
    return Row(
      children: [
        _QtyButton(
          icon: Icons.remove,
          onTap: () {
            if (value > 1) onChanged(value - 1);
          },
        ),
        Container(
          width: 46,
          alignment: Alignment.center,
          child: Text('$value', style: const TextStyle(fontSize: 16)),
        ),
        _QtyButton(
          icon: Icons.add,
          onTap: () {
            if (canInc) onChanged(value + 1);
          },
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
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
    if (idx > 1 && idx % 3 == 1) buf.write('.');
  }
  return buf.toString();
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$d/$m/$y';
}
