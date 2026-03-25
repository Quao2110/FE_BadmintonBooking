import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
    return BlocConsumer<CourtBloc, CourtState>(
      listener: (context, state) {
        if (state is CourtActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<CourtBloc>().add(const LoadAllCourts());
        } else if (state is CourtError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
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
                        Row(
                          children: [
                            Expanded(
                              child: _StatChip(
                                icon: Icons.sports_tennis_rounded,
                                label: 'Tong',
                                value: '${courts.length}',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatChip(
                                icon: Icons.check_circle_rounded,
                                label: 'Active',
                                value:
                                    '${courts.where((c) => c.status.toLowerCase() == 'active' || c.status.toLowerCase() == 'available').length}',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatChip(
                                icon: Icons.cancel_rounded,
                                label: 'Off',
                                value:
                                    '${courts.where((c) => c.status.toLowerCase() == 'maintenance' || c.status.toLowerCase() == 'inactive').length}',
                                color: Colors.red,
                              ),
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
                          .map(
                            (court) => _CourtCard(
                              court: court,
                              onEdit: () =>
                                  _showEditCourtDialog(context, court),
                              onUploadImage: () =>
                                  _showUploadImageDialog(context, court),
                            ),
                          )
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
                                                child: _SmartCourtImage(
                                                  imageUrl:
                                                      court.primaryImageUrl,
                                                  fallbackIcon:
                                                      Icons.sports_tennis,
                                                  fit: BoxFit.cover,
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
                                              Icons.edit_outlined,
                                              size: 20,
                                            ),
                                            color: Colors.orange,
                                            tooltip: 'Chỉnh sửa',
                                            onPressed: () =>
                                                _showEditCourtDialog(
                                                  context,
                                                  court,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 20,
                                            ),
                                            color: Colors.teal,
                                            tooltip: 'Thêm ảnh',
                                            onPressed: () =>
                                                _showUploadImageDialog(
                                                  context,
                                                  court,
                                                ),
                                          ),
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

  void _showUploadImageDialog(BuildContext context, CourtEntity court) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CourtBloc>(),
        child: _UploadCourtImageDialog(court: court),
      ),
    );
  }

  void _showEditCourtDialog(BuildContext context, CourtEntity court) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CourtBloc>(),
        child: _EditCourtDialog(court: court),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $value',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final CourtEntity court;
  final VoidCallback onEdit;
  final VoidCallback onUploadImage;

  const _CourtCard({
    required this.court,
    required this.onEdit,
    required this.onUploadImage,
  });

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
                          child: _SmartCourtImage(
                            imageUrl: court.primaryImageUrl,
                            fallbackIcon: Icons.sports_tennis,
                            fit: BoxFit.cover,
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
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Sửa'),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                  TextButton.icon(
                    onPressed: onUploadImage,
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                    ),
                    label: const Text('Thêm ảnh'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartCourtImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final BoxFit fit;

  const _SmartCourtImage({
    required this.imageUrl,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return Icon(fallbackIcon, color: Colors.grey);
    }

    if (raw.startsWith('data:image')) {
      try {
        final uriData = UriData.parse(raw);
        final bytes = uriData.contentAsBytes();
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.grey),
        );
      } catch (_) {
        final commaIndex = raw.indexOf(',');
        if (commaIndex > 0 && commaIndex < raw.length - 1) {
          try {
            var encoded = raw.substring(commaIndex + 1).replaceAll(RegExp(r'\s+'), '');
            final mod = encoded.length % 4;
            if (mod != 0) {
              encoded = '$encoded${'=' * (4 - mod)}';
            }
            final bytes = base64Decode(encoded);
            return Image.memory(
              bytes,
              fit: fit,
              errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.grey),
            );
          } catch (_) {
            return Icon(fallbackIcon, color: Colors.grey);
          }
        }
        return Icon(fallbackIcon, color: Colors.grey);
      }
    }

    return Image.network(
      ApiConstants.getFullImageUrl(raw),
      fit: fit,
      errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: Colors.grey),
    );
  }
}

class _EditCourtDialog extends StatefulWidget {
  final CourtEntity court;
  const _EditCourtDialog({required this.court});

  @override
  State<_EditCourtDialog> createState() => _EditCourtDialogState();
}

class _EditCourtDialogState extends State<_EditCourtDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  static const List<String> _statusOptions = [
    'Active',
    'Available',
    'Maintenance',
    'Inactive',
  ];
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.court.courtName);
    _descriptionCtrl = TextEditingController(text: widget.court.description ?? '');
    _status = _normalizeStatus(widget.court.status);
  }

  String _normalizeStatus(String raw) {
    final value = raw.trim().toLowerCase();
    for (final option in _statusOptions) {
      if (option.toLowerCase() == value) return option;
    }
    return 'Active';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CourtBloc>().add(
      UpdateCourt(
        courtId: widget.court.id,
        courtName: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        status: _status,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final maxDialogHeight = media.size.height * (isLandscape ? 0.72 : 0.62);

    return AlertDialog(
      title: const Text('Chỉnh sửa sân'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tên sân *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) {
                    final text = (v ?? '').trim();
                    if (text.isEmpty) return 'Vui lòng nhập tên sân';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionCtrl,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _statusOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? 'Active'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _UploadCourtImageDialog extends StatefulWidget {
  final CourtEntity court;
  const _UploadCourtImageDialog({required this.court});

  @override
  State<_UploadCourtImageDialog> createState() =>
      _UploadCourtImageDialogState();
}

class _UploadCourtImageDialogState extends State<_UploadCourtImageDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 92,
      );
      if (file != null && mounted) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submit() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh trước khi tải lên')),
      );
      return;
    }

    context.read<CourtBloc>().add(
      UploadCourtImage(courtId: widget.court.id, imageFile: _selectedImage!),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final maxDialogHeight = media.size.height * (isLandscape ? 0.82 : 0.72);
    final previewHeight = isLandscape ? 130.0 : 220.0;

    return AlertDialog(
      title: const Text('Tải ảnh sân'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sân: ${widget.court.courtName}'),
              const SizedBox(height: 4),
              SelectableText(
                'ID: ${widget.court.id}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: previewHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 8),
                            const Text('Chọn ảnh để xem trước'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn file'),
                  ),
                  if (_selectedImage != null)
                    SizedBox(
                      width: 220,
                      child: Text(
                        _selectedImage!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.upload),
          label: const Text('Tải lên'),
        ),
      ],
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
