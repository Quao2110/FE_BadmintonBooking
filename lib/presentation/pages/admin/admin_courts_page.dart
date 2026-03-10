import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/court_entity.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/api_constants.dart';
import 'admin_layout.dart';
import '../../../routes/app_router.dart';
import '../../bloc/court/court_bloc.dart';
import '../../bloc/court/court_event.dart';
import '../../bloc/court/court_state.dart';

/// Admin Courts Management Page
class AdminCourtsPage extends StatelessWidget {
  final User user;

  const AdminCourtsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      user: user,
      currentRoute: AppRoutes.adminCourts,
      child: BlocProvider(
        create: (_) => CourtBloc.create()..add(const LoadAllCourts()),
        child: const _AdminCourtsContent(),
      ),
    );
  }
}

class _AdminCourtsContent extends StatefulWidget {
  const _AdminCourtsContent();

  @override
  State<_AdminCourtsContent> createState() => _AdminCourtsContentState();
}

class _AdminCourtsContentState extends State<_AdminCourtsContent> {
  String _searchQuery = '';
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourtBloc, CourtState>(
      builder: (context, state) {
        List<CourtEntity> courts = [];
        if (state is CourtListLoaded) {
          courts = state.courts;
        }

        final filteredCourts = _searchQuery.isEmpty
            ? courts
            : courts
                  .where(
                    (c) => c.courtName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

        final totalPages = (filteredCourts.length / _rowsPerPage).ceil();
        final startIndex = _currentPage * _rowsPerPage;
        final endIndex = (startIndex + _rowsPerPage < filteredCourts.length)
            ? startIndex + _rowsPerPage
            : filteredCourts.length;
        final displayedCourts = filteredCourts.sublist(startIndex, endIndex);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Quản lý Sân Cầu Lông',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Làm mới',
                        onPressed: () => context.read<CourtBloc>().add(
                          const LoadAllCourts(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 24),

                  // Search & Stats
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _currentPage = 0;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm theo tên sân...',
                            hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 8 : 12,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              icon: Icons.sports_tennis_rounded,
                              label: 'Tổng',
                              value: '${courts.length}',
                              color: Colors.blue,
                            ),
                            _StatChip(
                              icon: Icons.check_circle_rounded,
                              label: 'Hoạt động',
                              value:
                                  '${courts.where((c) => c.status.toLowerCase() == 'active' || c.status.toLowerCase() == 'available').length}',
                              color: Colors.green,
                            ),
                            _StatChip(
                              icon: Icons.cancel_rounded,
                              label: 'Bảo trì',
                              value:
                                  '${courts.where((c) => c.status.toLowerCase() == 'maintenance' || c.status.toLowerCase() == 'inactive').length}',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 24),

                  // Loading / Empty / Content
                  if (state is CourtLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (filteredCourts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_tennis_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy sân',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isMobile)
                    // Mobile: Card layout
                    Column(
                      children: displayedCourts
                          .map((court) => _CourtCard(court: court))
                          .toList(),
                    )
                  else
                    // Desktop: DataTable
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey.shade50,
                              ),
                              columns: const [
                                DataColumn(label: Text('Hình ảnh')),
                                DataColumn(label: Text('Tên sân')),
                                DataColumn(label: Text('Mô tả')),
                                DataColumn(label: Text('Trạng thái')),
                                DataColumn(label: Text('Thao tác')),
                              ],
                              rows: displayedCourts.map((court) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: court.primaryImageUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  ApiConstants.getFullImageUrl(
                                                    court.primaryImageUrl!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                        Icons.sports_tennis,
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.sports_tennis,
                                                color: Colors.grey,
                                              ),
                                      ),
                                    ),
                                    DataCell(Text(court.courtName)),
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          court.description ?? 'Chưa có mô tả',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: court.description == null
                                                ? Colors.grey
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      _StatusBadge(status: court.status),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 20,
                                            ),
                                            color: Colors.blue,
                                            tooltip: 'Xem chi tiết',
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.courtDetail,
                                                arguments: court.id,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),

                          // Pagination
                          if (totalPages > 1)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hiển thị ${startIndex + 1}-$endIndex trong tổng ${filteredCourts.length}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _currentPage > 0
                                            ? () =>
                                                  setState(() => _currentPage--)
                                            : null,
                                      ),
                                      ...List.generate(totalPages, (index) {
                                        if (totalPages > 7 &&
                                            (index > 2 &&
                                                index < totalPages - 3 &&
                                                index != _currentPage)) {
                                          if (index == 3) {
                                            return const Text('...  ');
                                          }
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: InkWell(
                                            onTap: () => setState(
                                              () => _currentPage = index,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _currentPage == index
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _currentPage == index
                                                      ? AppColors.primary
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: _currentPage == index
                                                      ? Colors.white
                                                      : AppColors.textPrimary,
                                                  fontWeight:
                                                      _currentPage == index
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _currentPage < totalPages - 1
                                            ? () =>
                                                  setState(() => _currentPage++)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Mobile pagination
                  if (isMobile && totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          Text(
                            'Trang ${_currentPage + 1}/$totalPages',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final CourtEntity court;

  const _CourtCard({required this.court});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: court.primaryImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ApiConstants.getFullImageUrl(
                              court.primaryImageUrl!,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.sports_tennis,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.sports_tennis,
                          color: Colors.grey,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.courtName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        court.description ?? 'Chưa có mô tả',
                        style: TextStyle(
                          fontSize: 13,
                          color: court.description == null
                              ? Colors.grey
                              : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _StatusBadge(status: court.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.courtDetail,
                      arguments: court.id,
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Xem chi tiết'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive =
        status.toLowerCase() == 'active' || status.toLowerCase() == 'available';
    final isMaintenance =
        status.toLowerCase() == 'maintenance' ||
        status.toLowerCase() == 'inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade50
            : (isMaintenance ? Colors.red.shade50 : Colors.orange.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.shade200
              : (isMaintenance ? Colors.red.shade200 : Colors.orange.shade200),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive
              ? Colors.green.shade700
              : (isMaintenance ? Colors.red.shade700 : Colors.orange.shade700),
        ),
      ),
    );
  }
}
