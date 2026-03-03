import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../../routes/app_router.dart';
import '../../bloc/service/service_bloc.dart';
import '../../bloc/service/service_event.dart';
import '../../bloc/service/service_state.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  late final ServiceBloc _serviceBloc;

  @override
  void initState() {
    super.initState();
    _serviceBloc = ServiceBloc.create()..add(const GetServicesEvent());
  }

  @override
  void dispose() {
    _serviceBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceBloc>.value(
      value: _serviceBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          title: const Text('Dịch vụ cầu lông'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServiceLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ServiceListLoaded) {
                final items = state.services;
                if (items.isEmpty) {
                  return const Center(child: Text('Không có dịch vụ'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ServiceCard(
                      name: item.serviceName,
                      unit: item.unit,
                      price: item.price,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.serviceDetail,
                          arguments: ServiceDetailArgs(item.id),
                        );
                      },
                    );
                  },
                );
              }
              if (state is ServiceError) {
                return _InlineError(
                  message: state.message,
                  onRetry: () => _serviceBloc.add(const GetServicesEvent()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
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
    return Row(
      children: [
        Expanded(child: Text(message, style: const TextStyle(color: AppColors.textSecondary))),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final String unit;
  final double price;
  final VoidCallback onTap;
  const _ServiceCard({
    required this.name,
    required this.unit,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.build, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Đơn vị: $unit',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '₫${_formatCurrency(price)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
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
    if (idx > 1 && idx % 3 == 1) buf.write('.');
  }
  return buf.toString();
}
